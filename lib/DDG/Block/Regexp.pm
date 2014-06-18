package DDG::Block::Regexp;
# ABSTRACT: Block implementation to handle regexp based plugins

use Moo;
with qw( DDG::Block );

=head1 DESCRIPTION

=method parse_trigger

This function of L<DDG::Block> is overloaded to be sure the triggers given
are precompiled, through setting them to a scalar. Also a string given will
get converted to a regexp.

=cut

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
					if ( my @matches = $request->$attr =~ m/$_/ ) {
						push @results, $self->handle_request_matches($plugin,$request,@matches);
						return @results if $self->return_one && @results;
					} else {
						$self->trace("No match with",ref $plugin);
					}
				}
			}
		}
	}
	return @results;
}

1;