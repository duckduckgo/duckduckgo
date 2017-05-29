package DDG::GoodieRole::Dates;
# ABSTRACT: A role to allow Goodies to recognize and work with dates in different notations.

use strict;
use warnings;

use Moo::Role;

use DateTime;
use Devel::StackTrace;
use List::Util qw( first );
use Package::Stash;
use Try::Tiny;

# This appears to parse most/all of the big ones, however it doesn't present a regex
use DateTime::Format::HTTP;

my %short_month_to_number = (
    jan => 1,
    feb => 2,
    mar => 3,
    apr => 4,
    may => 5,
    jun => 6,
    jul => 7,
    aug => 8,
    sep => 9,
    oct => 10,
    nov => 11,
    dec => 12,
);

# Reused lists and components for below
my $short_day_of_week   = qr#Mon|Tue|Wed|Thu|Fri|Sat|Sun#i;
my $full_day_of_week   = qr#Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday#i;
my %full_month_to_short = map { lc $_ => substr($_, 0, 3) } qw(January February March April May June July August September October November December);
my %short_month_fix     = map { lc $_ => $_ } (values %full_month_to_short);
my $short_month         = qr#Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec#i;
my $full_month          = qr#January|February|March|April|May|June|July|August|September|October|November|December#i;
my $month_regex         = qr#$full_month|$short_month#;
my $time_24h            = qr#(?:(?:[0-1][0-9])|(?:2[0-3]))[:]?[0-5][0-9][:]?[0-5][0-9]#i;
my $time_12h            = qr#(?:(?:0[1-9])|(?:1[012])):[0-5][0-9]:[0-5][0-9]\s?(?:am|pm)#i;
my $time_with_optional_seconds = qr#
    (?:(?:[0-1][0-9])|(?:2[0-3]))[:]?[0-5][0-9](?:[:]?[0-5][0-9])? |
    (?:(?:0[1-9])|(?:1[012])):[0-5][0-9](?::[0-5][0-9])?\s?(?:am|pm)
#ix;
my $date_number         = qr#[0-3]?[0-9]#;
my $full_year           = qr#[0-9]{4}#;
my $relative_dates      = qr#
    now | today | tomorrow | yesterday |
    (?:(?:current|previous|next)\sday) |
    (?:next|last|this)\s(?:week|month|year) |
    (?:in\s(?:a|[0-9]+)\s(?:day|week|month|year)[s]?)(?:\stime)? |
    (?:(?:a|[0-9]+)\s(?:day|week|month|year)[s]?\sago)
#ix;

# Covering the ambiguous formats, like:
# DMY: 27/11/2014 with a variety of delimiters
# MDY: 11/27/2014 -- fundamentally non-sensical date format, for americans
my $date_delim              = qr#[\.\\/\,_-]#;
my $ambiguous_dates         = qr#(?:$date_number)$date_delim(?:$date_number)$date_delim(?:$full_year)#i;
my $ambiguous_dates_matches = qr#^(?<m>$date_number)$date_delim(?<d>$date_number)$date_delim(?<y>$full_year)$#i;

# like: 1st 2nd 3rd 4-20,24-30th 21st 22nd 23rd 31st
my $number_suffixes = qr#(?:st|nd|rd|th)#i;

# Timezones: https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations
my %tz_offsets = (
    ACDT  => '+1030',
    ACST  => '+0930',
    ACT   => '+0800',
    ADT   => '-0300',
    AEDT  => '+1100',
    AEST  => '+1000',
    AFT   => '+0430',
    AKDT  => '-0800',
    AKST  => '-0900',
    AMST  => '-0300',
    AMT   => '-0400',
    ART   => '-0300',
    AST   => '+0300',
    AWDT  => '+0900',
    AWST  => '+0800',
    AZOST => '-0100',
    AZT   => '+0400',
    BDT   => '+0800',
    BIOT  => '+0600',
    BIT   => '-1200',
    BOT   => '-0400',
    BRT   => '-0300',
    BST   => '+0100',
    BTT   => '+0600',
    CAT   => '+0200',
    CCT   => '+0630',
    CDT   => '-0500',
    CEDT  => '+0200',
    CEST  => '+0200',
    CET   => '+0100',
    CHADT => '+1345',
    CHAST => '+1245',
    CHOT  => '+0800',
    CHUT  => '+1000',
    CIST  => '-0800',
    CIT   => '+0800',
    CKT   => '-1000',
    CLST  => '-0300',
    CLT   => '-0400',
    COST  => '-0400',
    COT   => '-0500',
    CST   => '-0600',
    CT    => '+0800',
    CVT   => '-0100',
    CWST  => '+0845',
    CXT   => '+0700',
    ChST  => '+1000',
    DAVT  => '+0700',
    DDUT  => '+1000',
    DFT   => '+0100',
    EASST => '-0500',
    EAST  => '-0600',
    EAT   => '+0300',
    ECT   => '-0400',
    EDT   => '-0400',
    EEDT  => '+0300',
    EEST  => '+0300',
    EET   => '+0200',
    EGST  => '+0000',
    EGT   => '-0100',
    EIT   => '+0900',
    EST   => '-0500',
    FET   => '+0300',
    FJT   => '+1200',
    FKST  => '-0300',
    FKT   => '-0400',
    FNT   => '-0200',
    GALT  => '-0600',
    GAMT  => '-0900',
    GET   => '+0400',
    GFT   => '-0300',
    GILT  => '+1200',
    GIT   => '-0900',
    GMT   => '+0000',
    GST   => '-0200',
    GYT   => '-0400',
    HADT  => '-0900',
    HAEC  => '+0200',
    HAST  => '-1000',
    HKT   => '+0800',
    HMT   => '+0500',
    HOVT  => '+0700',
    HST   => '-1000',
    ICT   => '+0700',
    IDT   => '+0300',
    IOT   => '+0300',
    IRDT  => '+0430',
    IRKT  => '+0900',
    IRST  => '+0330',
    IST   => '+0530',
    JST   => '+0900',
    KGT   => '+0600',
    KOST  => '+1100',
    KRAT  => '+0700',
    KST   => '+0900',
    LHST  => '+1030',
    LINT  => '+1400',
    MAGT  => '+1200',
    MART  => '-0930',
    MAWT  => '+0500',
    MDT   => '-0600',
    MEST  => '+0200',
    MET   => '+0100',
    MHT   => '+1200',
    MIST  => '+1100',
    MIT   => '-0930',
    MMT   => '+0630',
    MSK   => '+0300',
    MST   => '-0700',
    MUT   => '+0400',
    MVT   => '+0500',
    MYT   => '+0800',
    NCT   => '+1100',
    NDT   => '-0230',
    NFT   => '+1130',
    NPT   => '+0545',
    NST   => '-0330',
    NT    => '-0330',
    NUT   => '-1100',
    NZDT  => '+1300',
    NZST  => '+1200',
    OMST  => '+0700',
    ORAT  => '-0500',
    PDT   => '-0700',
    PET   => '-0500',
    PETT  => '+1200',
    PGT   => '+1000',
    PHOT  => '+1300',
    PKT   => '+0500',
    PMDT  => '-0200',
    PMST  => '-0300',
    PONT  => '+1100',
    PST   => '-0800',
    PYST  => '-0300',
    PYT   => '-0400',
    RET   => '+0400',
    ROTT  => '-0300',
    SAKT  => '+1100',
    SAMT  => '+0400',
    SAST  => '+0200',
    SBT   => '+1100',
    SCT   => '+0400',
    SGT   => '+0800',
    SLST  => '+0530',
    SRT   => '-0300',
    SST   => '-1100',
    SYOT  => '+0300',
    TAHT  => '-1000',
    TFT   => '+0500',
    THA   => '+0700',
    TJT   => '+0500',
    TKT   => '+1300',
    TLT   => '+0900',
    TMT   => '+0500',
    TOT   => '+1300',
    TVT   => '+0500',
    UCT   => '+0000',
    ULAT  => '+0800',
    UTC   => '+0000',
    UYST  => '-0200',
    UYT   => '-0300',
    UZT   => '+0500',
    VET   => '-0430',
    VLAT  => '+1000',
    VOLT  => '+0400',
    VOST  => '+0600',
    VUT   => '+1100',
    WAKT  => '+1200',
    WAST  => '+0200',
    WAT   => '+0100',
    WEDT  => '+0100',
    WEST  => '+0100',
    WET   => '+0000',
    WIT   => '+0700',
    WST   => '+0800',
    YAKT  => '+1000',
    YEKT  => '+0600',
    Z     => '+0000',
);
my $tz_strings = join('|', keys %tz_offsets);
my $tz_suffixes = qr#(?:[+-][0-9]{4})|$tz_strings#i;

my $date_standard = qr#$short_day_of_week $short_month\s{1,2}$date_number $time_24h $tz_suffixes $full_year#i;
my $date_standard_matches = qr#$short_day_of_week (?<m>$short_month)\s{1,2}(?<d>$date_number) (?<t>$time_24h) (?<tz>$tz_suffixes) (?<y>$full_year)#i;

# formats parsed by vague datestring, without colouring
# the context of the code using it
my $descriptive_datestring = qr{
    (?:(?:next|last)\s(?:$month_regex)) |                        # next June, last jan
    (?:(?:$month_regex)\s(?:$full_year)) |                         # Jan 2014, August 2000
    (?:(?:$date_number)\s?$number_suffixes?\s(?:$month_regex)) | # 18th Jan, 01 October
    (?:(?:$month_regex)\s(?:$date_number)\s?$number_suffixes?) | # Dec 25, July 4th
    (?:$month_regex)                                           | # February, Aug
    (?:$relative_dates)                                        |  # next week, last month, this year
    (?:(?:$date_number)\s?$number_suffixes?\s(?:$month_regex)\s(?:$time_with_optional_seconds)) | # 22 may 08:00
    (?:(?:$time_with_optional_seconds)\s(?:$date_number)\s?$number_suffixes?\s(?:$month_regex)) # 08:00 22 may
    }ix;

# Used for parse_descriptive_datestring_to_date
my $descriptive_datestring_matches = qr#
    (?:(?<q>next|last)\s(?<m>$month_regex)) |
    (?:(?<m>$month_regex)\s(?<y>$full_year)) |
    (?:(?<d>$date_number)\s?$number_suffixes?\s(?<m>$month_regex)) |
    (?:(?<m>$month_regex)\s(?<d>$date_number)\s?$number_suffixes?) |
    (?<m>$month_regex) |
    (?<r>$relative_dates) |
    (?:(?<d>$date_number)\s?$number_suffixes?\s(?<m>$month_regex)\s(?<t>$time_with_optional_seconds)) |
    (?:(?<t>$time_with_optional_seconds)\s(?<d>$date_number)\s?$number_suffixes?\s(?<m>$month_regex))
    #ix;

my $formatted_datestring = build_datestring_regex();

# Accessors for useful regexes
sub full_year_regex {
	return $full_year;
}
sub full_month_regex {
    return $full_month;
}
sub short_month_regex {
    return $short_month;
}
sub month_regex {
    return $month_regex;
}
sub full_day_of_week_regex {
    return $full_day_of_week;
}
sub short_day_of_week_regex {
    return $short_day_of_week;
}
sub relative_dates_regex {
    return $relative_dates;
}
sub time_24h_regex {
    return $time_24h;
}
sub time_12h_regex {
    return $time_12h;
}

# Accessors for matching regexes
# These matches are for "in the right format"/"looks about right"
#  not "are valid dates"; expects normalised whitespace
sub datestring_regex {
    return qr#$formatted_datestring|$descriptive_datestring#i;
}

sub descriptive_datestring_regex {
    return $descriptive_datestring;
}

sub formatted_datestring_regex {
    return $formatted_datestring;
}

sub is_valid_year {
	my ($year) = @_;
	return ($year =~ /^[0-9]{1,4}$/)
		&& (1*$year > 0)
		&& (1*$year < 10000);
}

# Called once to build $formatted_datestring
sub build_datestring_regex {
    my @regexes = ();

    ## unambigous and awesome date formats:
    # ISO8601: 2014-11-27 (with a concession to single-digit month and day numbers)
    push @regexes, qr#$full_year-?[0-1]?[0-9]-?$date_number(?:[ T]$time_24h)?(?: ?$tz_suffixes)?#i;

    # HTTP: Sat, 09 Aug 2014 18:20:00
    push @regexes, qr#$short_day_of_week, [0-9]{2} $short_month $full_year $time_24h?#i;

    # HTTP (without day) any TZ: 09 Aug 2014 18:20:00 UTC
    push @regexes, qr#[0-9]{2} $short_month $full_year $time_24h(?: ?$tz_suffixes)?#i;

    # RFC850 08-Feb-94 14:15:29 GMT
    push @regexes, qr#[0-9]{2}-$short_month-(?:[0-9]{2}|$full_year) $time_24h?(?: ?$tz_suffixes)#i;

    # RFC2822 Sat, 13 Mar 2010 11:29:05 -0800
    push @regexes, qr#$short_day_of_week, $date_number $short_month $full_year $time_24h $tz_suffixes#i;

    # date(1) default format Sun Sep  7 15:57:56 EDT 2014
    push @regexes, $date_standard;

    # month-first date formats
    push @regexes, qr#$date_number (?:$full_month|$short_month) $full_year $time_24h#i;
    push @regexes, qr#$date_number$date_delim$short_month$date_delim$full_year(?: $time_24h)?#i;
    push @regexes, qr#$date_number$date_delim$full_month$date_delim$full_year(?: $time_24h)?#i;

    push @regexes, qr#(?:$short_month|$full_month) (?:the )?$date_number(?: ?$number_suffixes)?[,]? $full_year#i;

    # day-first date formats
    push @regexes, qr#$short_month$date_delim$date_number$date_delim$full_year#i;
    push @regexes, qr#$full_month$date_delim$date_number$date_delim$full_year#i;
    push @regexes, qr#$date_number[,]?(?: ?$number_suffixes)? (?:of )?(?:$short_month|$full_month)[,]? $full_year#i;

    ## Ambiguous, but potentially valid date formats
    push @regexes, $ambiguous_dates;

    my $returned_regex = join '|', @regexes;
    return qr/$returned_regex/i;
}

# Parses any string that *can* be parsed to a date object
sub parse_datestring_to_date {
    my ($d,$base) = @_;

    return parse_formatted_datestring_to_date($d) || parse_descriptive_datestring_to_date($d,$base);
}

# Accepts a string which looks like date per the supplied datestring_regex (e.g. '31/10/1980')
# Returns a DateTime object representing that date or `undef` if the string cannot be parsed.
sub parse_formatted_datestring_to_date {
    my ($d) = @_;

    return unless (defined $d && $d =~ qr/^$formatted_datestring$/);    # Only handle white-listed strings, even if they might otherwise work.

    if ($d =~ $ambiguous_dates_matches) {
        # guesswork for ambigous DMY/MDY and switch to ISO
        my ($month, $day, $year) = ($+{'m'}, $+{'d'}, $+{'y'});    # Assume MDY, even though it's crazy, for backward compatibility

        if ($month > 12) {
            # Months over 12 don't make any sense, so must not be MDY
            return if ($day > 12);                                 # what we took as day must not be month, either.  No idea how to proceed.
            ($day, $month) = ($month, $day);                       # month and day must be swapped, then.
        }

        $d = sprintf("%04d-%02d-%02d", $year, $month, $day);
    } elsif ($d =~ $date_standard_matches) {
        # To ISO8601 for parsing
        $d = sprintf('%04d-%02d-%02dT%s%s', $+{'y'}, $short_month_to_number{lc $+{'m'}}, $+{'d'}, $+{'t'}, $tz_offsets{$+{'tz'}});
    }

    $d =~ s/(\d+)\s?$number_suffixes/$1/i;                                       # Strip ordinal text.
    $d =~ s/(\sof\s)|(\sthe\s)/ /i;                                              # Strip "of" for "4th of march" and "the" for "march the 4th"
    $d =~ s/,//i;                                                                # Strip any random commas.
    $d =~ s/($full_month)/$full_month_to_short{lc $1}/i;                         # Parser deals better with the shorter month names.
    $d =~ s/^($short_month)$date_delim(\d{1,2})/$2-$short_month_fix{lc $1}/i;    # Switching Jun-01-2012 to 01 Jun 2012
    $d =~ s/(?<tz>$tz_strings)$/$tz_offsets{uc $1}/i;                            # Convert trailing timezones to actual offsets.

    my $maybe_date_object = try { DateTime::Format::HTTP->parse_datetime($d) };  # Don't die no matter how bad we did with checking our string.
    if (ref $maybe_date_object eq 'DateTime') {
        if (exists $+{tz}) {
            try { $maybe_date_object->set_time_zone(uc $+{tz}) };
        }
        if ($maybe_date_object->strftime('%Z') eq 'floating') {
            $maybe_date_object->set_time_zone(_get_timezone());
        };
    };

    return $maybe_date_object;
}

# parses multiple dates and guesses the consistent format over the set;
# i.e. defaults to m/d/y unless one of them is obviously d/m/y then it'll
# treat them all as d/m/y
sub parse_all_datestrings_to_date {
    my @dates = @_;

    # If there is an ambiguous date with a "month" over 12 in the set, we need to flip.
    my $flip_d_m = first { /$ambiguous_dates_matches/ && $+{'m'} > 12 } @dates;
    my @dates_to_return;
    foreach my $date (@dates) {
        if ($date =~ $ambiguous_dates_matches) {
            my ($month, $day, $year) = ($+{'m'}, $+{'d'}, $+{'y'});
            ($day, $month) = ($month, $day) if $flip_d_m;
            return if $month > 12;    #there's a mish-mash of formats; give up
            $date = "$year-$month-$day";
        }

        my $date_object = ($dates_to_return[0]
                            ? parse_datestring_to_date($date, $dates_to_return[0])
                            : parse_datestring_to_date($date)
                        );

        return unless $date_object;
        push @dates_to_return, $date_object;
    }

    return @dates_to_return;
}

sub get_timezones {
    return %tz_offsets;
}

sub _get_timezone {
    my $default_tz = 'UTC';    # If any of the below fails for some reason, we'll go with this

    my $tz = try {
        # Dig through how we got here, ignoring
        my $hit = 0;
        # We only care about the most recent caller who is some kinda goodie-looking thing.
        my $frame_filter = sub {
            my $frame_info = shift;
            if (!$hit && $frame_info->{caller}[0] =~ /^DDG::Goodie::/) { $hit++; return 1; }
            else                                                       { return 0; }
        };
        my $trace = Devel::StackTrace->new(
            frame_filter => $frame_filter,
            no_args      => 1,
        );
        my $stash = Package::Stash->new($trace->frame(0)->package);    # Get the package info for our caller.
        ${$stash->get_symbol('$loc')}->time_zone;                      # Give back the time_zone in the $loc variable on their package
    };

    return $tz || $default_tz;
}

# Parses a really vague description and basically guesses
sub parse_descriptive_datestring_to_date {
    my ($string, $base_time) = @_;

    return unless (defined $string && $string =~ qr/^$descriptive_datestring_matches$/);

    $base_time = DateTime->now(time_zone => _get_timezone()) unless($base_time);
    my $month = $+{'m'};           # Set in each alternative match.

    if (my $day = $+{'d'}) {
        my $timecomponent = "00:00:00";
        $timecomponent = $+{'t'} if($+{'t'});
        $timecomponent .= ":00" if($timecomponent =~ qr/^[0-9]{2}:[0-9]{2}$/);  #Seconds are optional; default to 0 if unspecified

        return parse_datestring_to_date("$day $month " . $base_time->year() . " $timecomponent");
    } elsif (my $relative_dir = $+{'q'}) {
        my $tmp_date = parse_datestring_to_date("01 $month " . $base_time->year());

        # for "next <month>"
        $tmp_date->add( years => 1) if ($relative_dir eq "next" && DateTime->compare($tmp_date, $base_time) != 1);
        # for "last <month>" if $tmp_date is in the future then we need to subtract a year
        $tmp_date->add(years => -1) if ($relative_dir eq "last" && DateTime->compare($tmp_date, $base_time) != -1);
        return $tmp_date;
    } elsif (my $year = $+{'y'}) {
        # Month and year is the first of that month.
        return parse_datestring_to_date("01 $month $year");
    } elsif (my $relative_date = $+{'r'}) {
        # relative dates, tomorrow, yesterday etc
        my $tmp_date = DateTime->now(time_zone => _get_timezone());
        my @to_add;
        if ($relative_date =~ qr/tomorrow|(?:next day)/) {
            @to_add = (days => 1);
        } elsif ($relative_date =~ qr/yesterday|(?:previous day)/) {
            @to_add = (days => -1);
        } elsif ($relative_date =~ qr/(?<dir>next|last|this) (?<unit>week|month|year)/) {
            my $unit = $+{'unit'};
            my $num = ($+{'dir'} eq 'next') ? 1 : ($+{'dir'} eq 'last') ? -1 : 0;
            @to_add = _util_add_unit($unit, $num);
        } elsif ($relative_date =~ qr/in (?<num>a|[0-9]+) (?<unit>day|week|month|year)/) {
            my $unit = $+{'unit'};
            my $num = ($+{'num'} eq "a" ? 1 : $+{'num'});
            @to_add = _util_add_unit($unit, $num);
        } elsif ($relative_date =~ qr/(?<num>a|[0-9]+) (?<unit>day|week|month|year)(?:[s])? ago/) {
            my $unit = $+{'unit'};
            my $num = ($+{'num'} eq "a" ? 1 : $+{'num'}) * -1;
            @to_add = _util_add_unit($unit, $num);
        }
        # Any other cases which came through here should be today.
        $tmp_date->add(@to_add);
        return $tmp_date;
    } else {
        # single named months
        # "january" in january means the current month
        # otherwise it always means the coming month of that name, be it this year or next year
        return parse_datestring_to_date("01 " . $base_time->month_name() . " " . $base_time->year()) if lc($base_time->month_name()) eq lc($month);
        my $this_years_month = parse_datestring_to_date("01 $month " . $base_time->year());
        $this_years_month->add(years => 1) if (DateTime->compare($this_years_month, $base_time) == -1);
        return $this_years_month;
    }
}

sub _util_add_unit {
    my ($unit, $num) = @_;
    my @to_add =
        ($unit eq 'day')   ? (days => $num)
      : ($unit eq 'week')  ? (days => 7*$num)
      : ($unit eq 'month') ? (months => $num)
      : ($unit eq 'year')  ? (years  => $num)
      :                      ();
    return @to_add;
}

# Takes a DateTime object (or a string which can be parsed into one)
# and returns a standard formatted output string or an empty string if it cannot be parsed.
sub date_output_string {
    my ($dt, $use_clock) = @_;

    my $ddg_format = "%d %b %Y";    # Just here to make it easy to see.
    my $ddg_clock_format = "%d %b %Y %T %Z"; # 01 Jan 2012 00:00:00 UTC (HTTP without day)
    my $date_format = $use_clock ? $ddg_clock_format : $ddg_format;
    my $string     = '';            # By default we've got nothing.
    # They didn't give us a DateTime object, let's try to make one from whatever we got.
    $dt = parse_datestring_to_date($dt) if (ref($dt) !~ /DateTime/);
    $string = $dt->strftime($date_format) if ($dt);

    return $string;
}

1;
