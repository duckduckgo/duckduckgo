package DDG::Plugin;

use Moo::Role;

requires qw(
	triggers
);

sub query {
	my ( $self, $query, $parameter ) = @_;
	return $self->simple_query($query->query,@{$parameter});
}

sub simple_query {}

1;