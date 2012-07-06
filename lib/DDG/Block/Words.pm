package DDG::Block::Words;
# ABSTRACT: Block implementation to handle words based plugins

use Moo;
use Carp;
with qw( DDG::Block );

sub BUILD {
	my ( $self ) = @_;
	for (reverse @{$self->plugin_objs}) {
		my $triggers = $_->[0];
		my $plugin = $_->[1];
		for (@{$triggers}) {
			my $trigger = $_;
			croak "trigger must be a hash on ".(ref $plugin) unless ref $trigger eq 'HASH';
			if (defined $trigger->{start}) {
				$self->_set_start_word_plugin($_,$plugin) for (@{$trigger->{start}});
			}
			if (defined $trigger->{end}) {
				$self->_set_end_word_plugin($_,$plugin) for (@{$trigger->{end}});
			}
			if (defined $trigger->{startend}) {
				$self->_set_start_word_plugin($_,$plugin) for (@{$trigger->{startend}});
				$self->_set_end_word_plugin($_,$plugin) for (@{$trigger->{startend}});
			}
			if (defined $trigger->{any}) {
				$self->_set_any_word_plugin($_,$plugin) for (@{$trigger->{any}});
			}
		}
	}
}

=head1 DESCRIPTION

...

On construction it fills up its own cache in L<words_plugins> by analyzing the
given plugins and their triggers.

=cut

sub _set_start_word_plugin { shift->_set_beginword_word_plugin('start',@_) }
sub _set_any_word_plugin { shift->_set_beginword_word_plugin('any',@_) }
sub _set_end_word_plugin { shift->_set_endword_word_plugin('end',@_) }

sub _set_endword_word_plugin {
	my ( $self, $type, $word, $plugin ) = @_;
	my @words = split(/\s+/,$word);
	$word = join(' ',@words);
	$self->_set_word_plugin($type,pop @words,$word,$plugin);
}

sub _set_beginword_word_plugin {
	my ( $self, $type, $word, $plugin ) = @_;
	my @words = split(/\s+/,$word);
	$word = join(' ',@words);
	$self->_set_word_plugin($type,shift @words,$word,$plugin);
}

sub _set_word_plugin {
	my ( $self, $type, $key, $word, $plugin ) = @_;
	my @split_word = split(/\s+/,$word);
	my $word_count = scalar @split_word;
	$self->_words_plugins->{$type}->{$key} = {} unless defined $self->_words_plugins->{$type}->{$key};
	if ($word_count eq 1) {
		$self->_words_plugins->{$type}->{$key}->{1} = $plugin;
	} else {
		$self->_words_plugins->{$type}->{$key}->{$word_count} = {} unless defined $self->_words_plugins->{$type}->{$key}->{$word_count};
		$self->_words_plugins->{$type}->{$key}->{$word_count}->{$word} = $plugin;
	}
}

=attr words_plugins

This private attribute is a cache for grouping the plugins into B<start>,
B<end> and B<any> based plugins.

=cut

has _words_plugins => (
	# like HashRef[HashRef[DDG::Block::Plugin]]',
	is => 'ro',
	lazy => 1,
	builder => 1,
);
sub words_plugins { shift->_words_plugins }

sub _build__words_plugins {{
	start => {},
	end => {},
	any => {},
}}

=method request

=cut

sub request {
	my ( $self, $request ) = @_;
	my @results;
	my %triggers = %{$request->triggers};
	my $max = scalar keys %triggers;
	my @poses = sort { $a <=> $b } keys %triggers;
	for my $cnt (0..$max-1) {
		my $start = $cnt == 0 ? 1 : 0;
		my $end = $cnt == $max-1 ? 1 : 0;
		for my $word (@{$request->triggers->{$poses[$cnt]}}) {
			if (my ( $begin, $hitstruct ) =
					$start && defined $self->_words_plugins->{start}->{$word}
						? ( 1 => $self->_words_plugins->{start}->{$word} )
						: $end && defined $self->_words_plugins->{end}->{$word}
							? ( 0 => $self->_words_plugins->{end}->{$word} )
							: defined $self->_words_plugins->{any}->{$word}
								? ( 1 => $self->_words_plugins->{any}->{$word} )
								: undef) {
				my $pos = $poses[$cnt];
				for my $word_count (sort { $b <=> $a } grep { $_ > 1 } keys %{$hitstruct}) {
					my @sofar_words = @{$triggers{$pos}};
					for (@sofar_words) {
						push @results, $hitstruct->{$word_count}->{$_}->handle_request_matches($request,$pos) if defined $hitstruct->{$word_count}->{$_};
						return @results if $self->return_one && @results;
					}
					my @next_poses_key = grep { $_ >= 0 } $begin ? ($cnt+1)..($cnt+$word_count-1) : ($cnt-$word_count-1)..($cnt-1);
					my @next_poses = grep { defined $_ && defined $triggers{$_} } @poses[@next_poses_key];
					@next_poses = reverse @next_poses unless $begin;
					for my $next_pos (@next_poses) {
						my @next_triggers = @{$triggers{$next_pos}};
						my @new_next_words;
						for my $next_trigger (@next_triggers) {
							for my $current_sofar_word (@sofar_words) {
								my $new_next_word = $begin
									? join(" ",$current_sofar_word,$next_trigger)
									: join(" ",$next_trigger,$current_sofar_word);
								push @results, $hitstruct->{$word_count}->{$new_next_word}->handle_request_matches($request,( $pos < $next_pos ) ? ( $pos,$next_pos ) : ( $next_pos,$pos ) ) if defined $hitstruct->{$word_count}->{$new_next_word};
								return @results if $self->return_one && @results;
								push @new_next_words, $new_next_word;
							}
						}
						push @sofar_words, @new_next_words;
					}
				}
				push @results, $hitstruct->{1}->handle_request_matches($request,$poses[$cnt]) if defined $hitstruct->{1};
				return @results if $self->return_one && @results;
			}
		}
	}
	return @results;
}

=method empty_trigger

Overloading this method from L<DDG::Block> assures that we dont allow any
plugin which as no triggers. Words plugins are all triggered via keywords
against a hash, which means there is no order relevance, which makes a
triggerless plugin just totally unclear, if it now needs to get started
before the hash compare or after (or not).

=cut

sub empty_trigger { croak "empty triggers are not supported by ".__PACKAGE__ }

1;