package DDG::Block::Any;

use Moo;
use Carp;
with qw( DDG::Block );

sub request {
	my ( $self, $request ) = @_;
	my @results;
	for (@{$self->triggers}) {
		push @results, $_->handle_request_matches($request);
		return @results if $self->return_one;
	}
	return @results;
}

sub get_triggers_of_plugin { return; }

1;