package DDG::Block::Words;

use Moo;
use Carp;
with qw( DDG::Block );

has _words_plugins => (
	# like HashRef[HashRef[DDG::Block::Plugin]]',
	is => 'ro',
	lazy => 1,
	builder => '_build__words_plugins',
);
sub words_plugins { shift->_words_plugins }

sub _build__words_plugins {
	my ( $self ) = @_;
	my %before;
	my %any;
	my %after;
	for (reverse @{$self->plugin_objs}) {
		my $triggers = $_->[0];
		my $plugin = $_->[1];
		for (@{$triggers}) {
			my $trigger = $_;
			croak "trigger must be a hash on ".(ref $plugin) unless ref $trigger eq 'HASH';
			if (defined $trigger->{before}) {
				for (@{$trigger->{before}}) {
					$before{$_} = $plugin;
				}
			}
			if (defined $trigger->{after}) {
				for (@{$trigger->{after}}) {
					$after{$_} = $plugin;
				}
			}
			if (defined $trigger->{around}) {
				for (@{$trigger->{around}}) {
					$before{$_} = $plugin;
					$after{$_} = $plugin;
				}
			}
			if (defined $trigger->{any}) {
				for (@{$trigger->{any}}) {
					$any{$_} = $plugin;
				}
			}
		}
	}
	return {
		before => \%before,
		after => \%after,
		any => \%any,
	};
}

sub request {
	my ( $self, $request ) = @_;
	my @results;
	my $cnt = 0;
	my $max = scalar keys %{$request->triggers};
	for my $pos (keys %{$request->triggers}) {
		$cnt++;
		my $start = $cnt == 1 ? 1 : 0;
		my $end = $cnt == $max ? 1 : 0;
		for my $word (@{$request->triggers->{$pos}}) {
			if (my $plugin =
				$start && defined $self->words_plugins->{before}->{$word} ? $self->words_plugins->{before}->{$word} :
				$end && defined $self->words_plugins->{after}->{$word} ? $self->words_plugins->{after}->{$word} :
				defined $self->words_plugins->{any}->{$word} ? $self->words_plugins->{any}->{$word} : undef) {				
				push @results, $plugin->handle_request_matches($request,$pos);
			}
		}
	}
	return @results;
}

sub get_triggers_of_plugin { shift; shift->all_words_by_type }

sub empty_trigger { croak "empty triggers are not supported by ".__PACKAGE__ }

sub BUILD {
	my ( $self ) = @_;
	$self->words_plugins;
}

1;