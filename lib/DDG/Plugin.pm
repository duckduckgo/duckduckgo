package DDG::Plugin;

use Moo::Role;

sub query {
	my ( $self, $query, $parameter ) = @_;
	return $self->simple_query($query->query_normalized,@{$parameter});
}

sub simple_query {}

1;