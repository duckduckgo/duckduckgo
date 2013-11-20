package DDG::Block::Any;
# ABSTRACT: EXPERIMENTAL

use Moo;
use Carp;
with qw( DDG::Block );

sub request {
	my ( $self, $request ) = @_;
	my @results;
	for (@{$self->plugin_objs}) {
		my $trigger = $_->[0];
		my $plugin = $_->[1];
		if ( $plugin->does('HasRequestHandler') ) {
			push @results, $self->handle_request_matches($plugin,$request,0);
			return @results if $self->return_one && @results;
		} else {
			@results = ()
		}
	}
	return @results;
}

sub get_triggers_of_plugin { return; }

1;