package DDG::Block::Regexp;

use Moo;
with qw( DDG::Block );

sub parse_trigger {
	my ( $self, $triggers ) = @_;
	for my $key (keys %{$triggers}) {
		my @triggers = map {
			ref $_ eq 'Regexp' ? $_ : qr{$_};
		} @{$triggers->{$key}};
		$triggers->{$key} = \@triggers;
	}
	return $triggers;
}

sub request {
	my ( $self, $request ) = @_;
	my @results;
	for (@{$self->plugin_objs}) {
		my $triggers = $_->[0];
		my $plugin = $_->[1];
		for my $trigger (@{$triggers}) {
			for my $attr (keys %{$trigger}) {
				for (@{$trigger->{$attr}}) {
					if ( my @matches = $request->$attr =~ m/$_/i ) {
						push @results, $plugin->handle_request_matches($request,@matches);
						return @results if $self->return_one && @results;
					}
				}
			}
		}
	}
	return @results;
}

sub get_triggers_of_plugin { shift; shift->all_regexps_by_type }

1;