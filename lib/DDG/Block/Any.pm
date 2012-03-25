package DDG::Block::Any;

use Moo;
use Carp;
with qw( DDG::Block );

#  _______  ______  _____ ____  ___ __  __ _____ _   _ _____  _    _
# | ____\ \/ /  _ \| ____|  _ \|_ _|  \/  | ____| \ | |_   _|/ \  | |
# |  _|  \  /| |_) |  _| | |_) || || |\/| |  _| |  \| | | | / _ \ | |
# | |___ /  \|  __/| |___|  _ < | || |  | | |___| |\  | | |/ ___ \| |___
# |_____/_/\_\_|   |_____|_| \_\___|_|  |_|_____|_| \_| |_/_/   \_\_____|
#
# API MIGHT CHANGE
#

sub request {
	my ( $self, $request ) = @_;
	my @results;
	for (@{$self->plugin_objs}) {
		my $trigger = $_->[0];
		my $plugin = $_->[1];
		push @results, $plugin->handle_request_matches($request,0);
		return @results if $self->return_one;
	}
	return @results;
}

sub get_triggers_of_plugin { return; }

1;