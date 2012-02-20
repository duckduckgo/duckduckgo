package DDG::Request;

use Moo;

#
# QUERY
#
###############################

has query_unmodified => (
	is => 'ro',
	required => 1,
);

my $whitespaces = qr{\s+};

has nowhitespaces => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nowhitespaces',
);
sub _build_nowhitespaces {
	my $q = shift->query;
	$q =~ s/$whitespaces//g;
	return $q;
}

my $whitespaces_dashes = qr{[\s\-]+};

has nowhitespaces_nodashes => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nowhitespaces_nodashes',
);
sub _build_nowhitespaces_nodashes {
	my $q = shift->query;
	$q =~ s/$whitespaces_dashes//g;
	return $q;
}

my $query_start_filter = qr{^\!};
my $query_end_filter = qr{\?$};

has query => (
	is => 'ro',
	lazy => 1,
	builder => '_build_query',
);
sub _build_query {
	my $q = join(' ',@{shift->words_unmodified});
	$q =~ s/$query_start_filter//;
	$q =~ s/$query_end_filter//;
	return $q;
}

has words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_words',
);
sub _build_words {
	my ( $self ) = @_;
	my @text_words;
	for (@{$self->words_unmodified}) {
		my $word = $_;
		$word =~ s/[\W\.]/ /g;
		for (split(/\s+/,$word)) {
			push @text_words, $_ unless $_ eq '';
		}
	}
	return \@text_words;
}

has words_unmodified => (
	is => 'ro',
	lazy => 1,
	builder => '_build_words_unmodified',
);
sub _build_words_unmodified {
	my ( $self ) = @_;
	my @words;
	for (split(/[ \t\n]+/,$self->query_unmodified)) {
		push @words, $_ unless $_ eq '';
	}
	return \@words;
}

has lc_query => (
	is => 'ro',
	lazy => 1,
	builder => '_build_lc_query',
);
sub _build_lc_query { lc(shift->query) }

has wordcount => (
	is => 'ro',
	lazy => 1,
	builder => '_build_wordcount',
);
sub _build_wordcount { scalar @{shift->words} }

has wordcount_unmodified => (
	is => 'ro',
	lazy => 1,
	builder => '_build_wordcount_unmodified',
);
sub _build_wordcount_unmodified { scalar @{shift->words_unmodified} }

has lc_words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_lc_words',
);
sub _build_lc_words {
	my ( $self ) = @_;
	my @lc_words;
	push @lc_words, lc($_) for (@{$self->words});
	return \@lc_words;
}

# combined lc words cache
has _clwc => (
	is => 'ro',
	default => sub {{}},
);

sub combined_lc_words {
	my ( $self, $count ) = @_;
	return [] if $count > $self->wordcount;
	if ( !defined $self->_clwc->{$count} ) {
		if ($count == $self->wordcount) {
			$self->_clwc->{$count} = [join(' ',@{$self->lc_words})];
		} else {
			my @words = @{$self->lc_words};
			my @clw;
			for (1..($self->wordcount - $count + 1)) {
				my $start = $_ - 1;
				my $end = $count + $start - 1;
				push @clw, join(' ',@words[$start..$end]);
			}
			$self->_clwc->{$count} = \@clw;
		}
	}
	return $self->_clwc->{$count};
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