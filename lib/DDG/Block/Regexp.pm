package DDG::Block::Regexp;

use Moo;
with qw( DDG::Block );

sub parse_trigger {
	my ( $self, $trigger ) = @_;
	return $trigger if ref $trigger eq 'Regexp';
	return qr{$trigger};
}

sub query {
	my ( $self, $query, @args ) = @_;
	my @results;
	for (@{$self->plugin_objs}) {
		my $re = $_->[0];
		my @matches = $query =~ /$re/;
		if (!$re || ( my @matches = $query =~ /$re/ ) ) {
			my $plugin = $_->[1];
			my @return = $plugin->query($query,\@matches,@args);
			if (@return) {
				if ($self->return_one) {
					return @return;
				} else {
					push @results, $_ for @return;
				}
			}
		}
	}
	return @results;
}

1;