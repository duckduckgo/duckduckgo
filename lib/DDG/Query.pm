package DDG::Query;

use Moo;

has query => (
	is => 'ro',
	required => 1,
);

has words => (
	is => 'ro',
	lazy => 1,
	builder => '_build_words',
);

sub _build_words {
	my ( $self ) = @_;
	my @words;
	for (split(/[ \t\n]+/,$self->query)) {
		push @words, $_ unless $_ eq '';
	}
	return \@words;
}

1;