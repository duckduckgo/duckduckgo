package DDG::Block::Regexp;

use Moo;
with qw( DDG::Block );

sub parse_trigger {
	my ( $self, $trigger ) = @_;
	return $trigger if ref $trigger eq 'Regexp';
	return qr{$trigger};
}

sub request {
	my ( $self, $query, @args ) = @_;
	my @results;
	my $query_string = $query->query;
	for (@{$self->plugin_objs}) {
		my $res = $_->[0];
		my $plugin = $_->[1];
		for (@{$res}) {
			if (!$_ || ( my @matches = $query_string =~ $_ ) ) {
				my @return = $plugin->query($query,\@matches,@args);
				if (@return) {
					if ($self->return_one) {
						return @return;
					} else {
						push @results, $_ for @return;
					}
					last;
				}
			}
		}
	}
	return @results;
}

sub get_triggers_of_plugin { shift; shift->all_regexps_by_type }

1;