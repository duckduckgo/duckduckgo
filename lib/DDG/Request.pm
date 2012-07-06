package DDG::Request;
# ABSTRACT: A request to DuckDuckGo itself, so the query itself and parameter around the query defining him

use Moo;
use utf8;
use List::MoreUtils qw{ uniq };

=head1 SYNOPSIS

  my $req = DDG::Request->new( query_raw => "Peter PAUL AND MARY!" );
  print $req->query_clean; # "peter paul and mary"

=head1 DESCRIPTION

This is the main request class which reflects a query and all parameter that
are relevant for plugins to work with the request. It does not reflect a web
request itself to DuckDuckGo, for this we have internal classes. The request
class is the abstracted level all services can independently work with, on any
medium, so also on the API, or via console based tests without web
environment. This class is also base for run on a L<DDG::Block>.

Beside the information of the query itself, a L<DDG::Request> can also contain
the language, the region and the geo location (which is calculated out of the
IP).

=cut

#
# QUERY
#
###############################

=attr query_raw

This is the only required attribute. It is the query in the most raw form. If
the query is given over special ways (like coming out of a hard url like
L<https://duckduckgo.com/Star_Trek_Voyager>), then those most get converted to
the text that is normally shown on the query line then, before given to
L</query_raw>.

=cut

has query_raw => (
	is => 'ro',
	required => 1,
);

my $whitespaces = qr{\s+};
my $whitespaces_matches = qr{($whitespaces)};
my $whitespaces_dashes = qr{[\s\-]+};
my $dashes = qr{\-+};
my $non_alphanumeric_ascii = qr{[\x00-\x1f\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x81\x{a7}]+};

=attr query_raw_parts

This attribute gets generated out of the L</query_raw>, which gets split into
all whitespace and non-whitespace content. For example the query:

  DDG::Request->new( query_raw => "A++    B++" );

would give you the following arrayref on L</query_raw_parts>:

  [
    'A++',
    '    ',
    'B++',
  ]

It preserves the exactly content of the query also the current amount of
whitespaces. Always the even index positions of the arrayref is the non
whitespace content. So if you have the query:

  DDG::Request->new( query_raw => "  A++    B++  " );

leads to this L</query_raw_parts> to fulfill this:

  [
    '',
    '  '
    'A++',
    '    ',
    'B++',
    '  ',
  ]

=cut

has query_raw_parts => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_raw_parts',
);
sub _build_query_raw_parts {
	[
		split(/$whitespaces_matches/,shift->query_raw)
	]
}

=attr query_parts

This functions filters out the whitespace parts and empty parts of
L</query_raw_parts>. Also it cuts down all part which would exceed making the
query more then 100 non whitespace characters.

=cut

has query_parts => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_parts',
);
sub _build_query_parts {
	my $x;
	[
		grep { ( $x += length ) < 100 }
		grep { ! /$whitespaces/ } 
		grep { length }
		@{shift->query_raw_parts}
	]
}

=attr query_parts_lc

This takes the arrayref of L</query_parts> and makes a lowercase arrayref
version of it.

=cut

has query_parts_lc => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_parts_lc',
);
sub _build_query_parts_lc {
	[
		map { lc }
		@{shift->query_parts}
	]
}

=attr triggers

Triggers generate a hashref construction which makes it very easy to parse a
query very effective through the accessing it word by word and so just
analyzing against as less combinations as possible.

It uses L</query_raw_parts> for this, but ignores the whitespace parts. Then it
passes every part through L</generate_triggers> which gives back all possible
variants of the specific given part.

=cut

has triggers => (
	is => 'ro',
	lazy => 1,
	builder => '_build_triggers',
);
sub _build_triggers {
	my ( $self ) = @_;
	my @parts = @{$self->query_raw_parts};
	my $x = $parts[0] eq '' ? 2 : 0;
	my %triggers;
	for ($x..(scalar @parts-1)) {
		unless ($_ % 2) {
			$triggers{$_} = [$self->generate_triggers($parts[$_])];
		}
	}
	return \%triggers;
}

=method generate_triggers

This function takes a part of L</query_raw_parts> and generates all possible
variants of it, also doing some magic with dash given words to give both
single or combined without dash or only with space. For specific analyze what
triggers are generated out of a part please read the function.

=cut

sub generate_triggers {
	my ( $self, $original_part ) = @_;
	my $part = $original_part;
	my @parts = (lc($part));
	$part =~ s/^!//g;
	push @parts, lc($part);
	$part =~ s/\?$//g;
	push @parts, lc($part);
	if ($part =~ m/$dashes/) {
		my @dashparts = split(/$dashes/, $part);
		for my $dashpart (@dashparts) {
			push @parts, lc($dashpart);
		}
		push @parts, lc($_) for @dashparts;
		my $joined = join('', @dashparts);
		push @parts, lc($joined);
		my $space_joined = join(' ', @dashparts);
		push @parts, lc($space_joined);
	}
	return uniq sort @parts;
}

=method generate_remainder

The method takes 2 index positions of L</query_raw_parts> to give out the other
parts of the query which is ot between them, so removes those parts and
generates out of the rest again a string which can be given to a plugin for
example.

It doesnt check which one is bigger, the first one must always be lower then
the second one given. You can also just give one index position.

=cut

sub generate_remainder {
	my ( $self, $from_pos, $to_pos ) = @_;
	$to_pos = $from_pos unless defined $to_pos;
	my @query_raw_parts = @{$self->query_raw_parts};
	my $max = scalar @query_raw_parts-1;
	my $remainder = '';
	if ( $to_pos < $max && ( $from_pos == 0 || ( $from_pos == 2 && $query_raw_parts[0] eq '' ) ) ) {
		$remainder = join('',@query_raw_parts[$to_pos+1..$max]);
		$remainder =~ s/^\s//;
	} elsif ( $max % 2 ? $to_pos == $max-1 : $to_pos == $max ) {
		$remainder = join('',@query_raw_parts[0..$from_pos-1]);
		$remainder =~ s/\s$//;
	} else {
		my $left_remainder = join('',@query_raw_parts[0..$from_pos-1]);
		my $right_remainder = join('',@query_raw_parts[$to_pos+1..$max]);
		$left_remainder =~ s/\s$//;
		$right_remainder =~ s/^\s//;
		$remainder = $left_remainder.' '.$right_remainder;
	}
	return $remainder;
}

=attr query

Takes L</query_parts> and join them with one space.

=cut

has query => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query',
);
sub _build_query {
	join(' ',@{shift->query_parts})
}

=attr query_lc

Takes L</query> and lowercases it.

=cut

has query_lc => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_lc',
);
sub _build_query_lc {
	lc(shift->query)
}

=attr query_nowhitespace

Takes L</query> and removes all whitespaces.

=cut

has query_nowhitespace => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_nowhitespace',
);
sub _build_query_nowhitespace {
	for (shift->query) {
		s/$whitespaces//g;
		return $_;
	}
}

=attr query_nowhitespace_nodash

Takes L</query> and removes all whitespaces and dashes.

=cut

has query_nowhitespace_nodash => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_nowhitespace_nodash',
);
sub _build_query_nowhitespace_nodash {
	for (shift->query) {
		s/$whitespaces_dashes//g;
		return $_;
	}
}

=attr query_clean

Takes L</query_lc> and removes all whitespaces and all non alphanumeric ascii.

=cut

has query_clean => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_clean',
);
sub _build_query_clean {
	for (shift->query_lc) {
		s/$non_alphanumeric_ascii//g;
		s/$whitespaces/ /g;
		return $_;
	}
}

=attr words

Takes L</query_clean> and generates an arrayref of the non-whitespace parts.

=cut

has words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_words',
);
sub _build_words {
	[
		grep { length }
		split(/$whitespaces/,shift->query_clean)
	]
}

=attr wordcount

Is the count of the elements in L</words>

=cut

has wordcount => (
	is => 'ro',
	lazy => 1,
	builder => '_build_wordcount',
);
sub _build_wordcount { scalar @{shift->words} }

#
# LANGUAGE / LOCATION / IP
#
###############################

#
# TODO
#

has lang => (
	is => 'ro',
	predicate => 'has_lang',
);

has ip => (
	is => 'ro',
	predicate => 'has_ip',
);

has geo_ip => (
	is => 'ro',
	predicate => 'has_geo_ip',
);

has _geo_ip_record => (
	is => 'ro',
	lazy => 1,
	builder => '_build__geo_ip_record',
);
sub _build__geo_ip_record { $_[0]->geo_ip->record_by_name($_[0]->ip) }

sub location { $_[0]->_geo_ip_record if $_[0]->has_location }
sub has_location { $_[0]->has_ip && $_[0]->has_geo_ip }

1;
