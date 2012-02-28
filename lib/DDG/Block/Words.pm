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
	my %start;
	my %any;
	my %end;
	for (reverse @{$self->plugin_objs}) {
		my $triggers = $_->[0];
		my $plugin = $_->[1];
		for (@{$triggers}) {
			my $trigger = $_;
			croak "trigger must be a hash on ".(ref $plugin) unless ref $trigger eq 'HASH';
			if (defined $trigger->{start}) {
				for (@{$trigger->{start}}) {
					$start{$_} = $plugin;
				}
			}
			if (defined $trigger->{end}) {
				for (@{$trigger->{end}}) {
					$end{$_} = $plugin;
				}
			}
			if (defined $trigger->{startend}) {
				for (@{$trigger->{startend}}) {
					$start{$_} = $plugin;
					$end{$_} = $plugin;
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
		start => \%start,
		end => \%end,
		any => \%any,
	};
}

sub request {
	my ( $self, $request ) = @_;
	my @results;
	my $cnt = 0;
	my $max = scalar keys %{$request->triggers};
	for my $pos (sort { $a <=> $b } keys %{$request->triggers}) {
		$cnt++;
		my $start = $cnt == 1 ? 1 : 0;
		my $end = $cnt == $max ? 1 : 0;
		for my $word (@{$request->triggers->{$pos}}) {
			if (my $plugin =
				$start && defined $self->words_plugins->{start}->{$word} ? $self->words_plugins->{start}->{$word} :
				$end && defined $self->words_plugins->{end}->{$word} ? $self->words_plugins->{end}->{$word} :
				defined $self->words_plugins->{any}->{$word} ? $self->words_plugins->{any}->{$word} : undef) {				
				push @results, $plugin->handle_request_matches($request,$pos);
				return @results if $self->return_one && @results;
			}
		}
	}
	return @results;
}

sub empty_trigger { croak "empty triggers are not supported by ".__PACKAGE__ }

sub BUILD {
	my ( $self ) = @_;
	$self->words_plugins;
}

1;