package DDG::Request;

use Moo;
use utf8;
use List::MoreUtils qw{ uniq };

#
# QUERY
#
###############################

has query_raw => (
	is => 'ro',
	required => 1,
);

my $whitespaces = qr{\s+};
my $whitespaces_matches = qr{($whitespaces)};
my $whitespaces_dashes = qr{[\s\-]+};
my $dashes = qr{\-+};
my $non_alphanumeric_ascii = qr{[\x00-\x1f\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x81\x{a7}]+};

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
			$triggers{$_} = [uniq sort $self->generate_triggers($parts[$_])];
		}
	}
	return \%triggers;
}

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
	}
	return @parts;
}

sub generate_remainder {
	my ( $self, $pos ) = @_;
	my @query_raw_parts = @{$self->query_raw_parts};
	my $max = scalar @query_raw_parts-1;
	my $remainder = '';
	if ( $pos < $max && ( $pos == 0 || ( $pos == 2 && $query_raw_parts[0] eq '' ) ) ) {
		$remainder = join('',@query_raw_parts[$pos+1..$max]);
		$remainder =~ s/^\s//;
	} elsif ( $max % 2 ? $pos == $max-1 : $pos == $max ) {
		$remainder = join('',@query_raw_parts[0..$pos-1]);
		$remainder =~ s/\s$//;
	} else {
		my $left_remainder = join('',@query_raw_parts[0..$pos-1]);
		my $right_remainder = join('',@query_raw_parts[$pos+1..$max]);
		$left_remainder =~ s/\s$//;
		$right_remainder =~ s/^\s//;
		$remainder = $left_remainder.' '.$right_remainder;
	}
	return $remainder;
}

has query => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query',
);
sub _build_query {
	join(' ',@{shift->query_parts})
}

has query_lc => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_lc',
);
sub _build_query_lc {
	lc(shift->query)
}

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

has wordcount => (
	is => 'ro',
	lazy => 1,
	builder => '_build_wordcount',
);
sub _build_wordcount { scalar @{shift->words} }

# combined words cache
has _cwc => (
	is => 'ro',
	default => sub {{}},
);

sub combined_words {
	my ( $self, $count ) = @_;
	return [] if $count > $self->wordcount;
	if ( !defined $self->_cwc->{$count} ) {
		if ($count == $self->wordcount) {
			$self->_cwc->{$count} = [join(' ',@{$self->words})];
		} else {
			my @words = @{$self->words};
			my @clw;
			for (1..($self->wordcount - $count + 1)) {
				my $start = $_ - 1;
				my $end = $count + $start - 1;
				push @clw, join(' ',@words[$start..$end]);
			}
			$self->_cwc->{$count} = \@clw;
		}
	}
	return $self->_cwc->{$count};
}

#
# LANGUAGE / LOCATION / IP
#
###############################

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
