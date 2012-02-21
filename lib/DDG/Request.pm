package DDG::Request;

use Moo;

#
# QUERY
#
###############################

has query_raw => (
	is => 'ro',
	required => 1,
);

my $whitespaces = qr{\s+};

has query_parts => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_parts',
);
sub _build_query_parts {
	my @words;
	for (split(/$whitespaces/,shift->query_raw)) {
		push @words, $_ unless $_ eq '';
	}
	return \@words;
}

my $query_start_filter = qr{^\!};
my $query_end_filter = qr{\?$};

has query => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query',
);
sub _build_query {
	my $q = join(' ',@{shift->query_parts});
	$q =~ s/$query_start_filter//;
	$q =~ s/$query_end_filter//;
	return $q;
}

has query_lc => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_lc',
);
sub _build_query_lc { lc(shift->query) }

has query_nowhitespace => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_nowhitespace',
);
sub _build_query_nowhitespace {
	my $q = shift->query;
	$q =~ s/$whitespaces//g;
	return $q;
}

my $whitespaces_dashes = qr{[\s\-]+};

has query_nowhitespace_nodash => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_nowhitespace_nodash',
);
sub _build_query_nowhitespace_nodash {
	my $q = shift->query;
	$q =~ s/$whitespaces_dashes//g;
	return $q;
}

my $non_alphanumeric_ascii = qr{[\x00-\x1f\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x81]+};

has query_clean => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query_clean',
);
sub _build_query_clean {
	my $q = shift->query_lc;
	$q =~ s/$non_alphanumeric_ascii//g;
	$q = substr($q,0,100);
	return $q;
}

has words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_words',
);
sub _build_words {
	my @words;
	for (split(/$whitespaces/,shift->query_clean)) {
		push @words, $_ unless $_ eq '';
	}
	return \@words;
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
