package DDG::Query;

use Moo;

#
# QUERY
#
###############################

has query_unmodified => (
	is => 'ro',
	required => 1,
);

my $whitechars = qr{[\s\n\t]+};

has nowhitechars => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nowhitechars',
);
sub _build_nowhitechars {
	my $q = shift->query;
	$q =~ s/$whitechars//g;
	return $q;
}

my $whitechars_dashes = qr{[\s\n\t\-]+};

has nowhitechars_nodashes => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nowhitechars_nodashes',
);
sub _build_nowhitechars_nodashes {
	my $q = shift->query;
	$q =~ s/$whitechars_dashes//g;
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
	my $q = join(' ',@{shift->words});
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
	my @words;
	for (split(/[ \t\n]+/,$self->query_unmodified)) {
		push @words, $_ unless $_ eq '';
	}
	return \@words;
}

has text_words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_text_words',
);
sub _build_text_words {
	my ( $self ) = @_;
	my @text_words;
	for (@{$self->words}) {
		my $word = $_;
		$word =~ s/[\W_]//g;
		push @text_words, $word unless $word eq '';
	}
	return \@text_words;
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

has text_wordcount => (
	is => 'ro',
	lazy => 1,
	builder => '_build_text_wordcount',
);
sub _build_text_wordcount { scalar @{shift->text_words} }

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

has lc_text_words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_lc_text_words',
);
sub _build_lc_text_words {
	my ( $self ) = @_;
	my @lc_text_words;
	push @lc_text_words, lc($_) for (@{$self->text_words});
	return \@lc_text_words;
}

# combined lc word cache
has _clwc => (
	is => 'ro',
	default => sub {{}},
);

sub combined_lc_text_words {
	my ( $self, $count ) = @_;
	return unless $count >= $self->text_wordcount;
	if ( !defined $self->_clwc->{$count} ) {
		$self->_clwc->{$count} = [$self->query_normalized] if $count == $self->wordcount;
		my @words = @{$self->lc_words};
		my @clw;
		for (1..($self->wordcount - $count + 1)) {
			my $start = $_ - 1;
			my $end = $count + $start;
			push @clw, join(' ',@words[$start..$end]);
		}
		$self->_clwc->{$count} = \@clw;
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