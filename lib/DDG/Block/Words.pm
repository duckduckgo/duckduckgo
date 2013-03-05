package DDG::Block::Words;
# ABSTRACT: Block implementation to handle words based plugins

use Moo;
use Carp;
with qw( DDG::Block );

sub BUILD {
	my ( $self ) = @_;
	for (@{$self->plugin_objs}) {
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
		$self->_words_plugins->{$type}->{$key}->{1} = [] unless defined $self->_words_plugins->{$type}->{$key}->{$word_count};
		push @{$self->_words_plugins->{$type}->{$key}->{1}}, $plugin;
	} else {
		$self->_words_plugins->{$type}->{$key}->{$word_count} = {} unless defined $self->_words_plugins->{$type}->{$key}->{$word_count};
		$self->_words_plugins->{$type}->{$key}->{$word_count}->{$word} = [] unless defined $self->_words_plugins->{$type}->{$key}->{$word_count}->{$word};
		push @{$self->_words_plugins->{$type}->{$key}->{$word_count}->{$word}}, $plugin;
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
	$self->trace( "Query raw: ", "'".$request->query_raw."'" );
	#
	# Mapping positions of keywords in the request
	# to a flat array which we can access stepwise.
	#
	# So @poses is an array of the positions inside
	# the triggers hash.
	#
	################################################
	my %triggers = %{$request->triggers};
	my $max = scalar keys %triggers;
	my @poses = sort { $a <=> $b } keys %triggers;
	$self->trace( "Trigger word positions: ", @poses );
	for my $cnt (0..$max-1) {
		#
		# We do split up this into a flat array to have it
		# easier to determine if the query is starting, ending
		# or still in the beginning, this is very essential
		# for the following steps.
		#
		my $start = $cnt == 0 ? 1 : 0;
		my $end = $cnt == $max-1 ? 1 : 0;
		for my $word (@{$request->triggers->{$poses[$cnt]}}) {
			$self->trace( "Testing word:", "'".$word."'" );
			#
			# Checking if any of the plugins have this specific word
			# in the start end or any trigger. start and end of course
			# only if its first or last word in the query.
			#
			# It gives back a touple of 2 elements, a bool which defines
			# if there COULD BE more words after it (so this fits for
			# any and start triggers), the second is the part of the
			# prepared trigger set of the blocks which is responsible
			# for this word.
			#
			# The keys inside the hitstruct define the words count it
			# additional carries. This allows to kick out the ones which
			# are not fitting anymore into the length of the query (by
			# wordcount)
			#
			if (my ( $begin, $hitstruct ) =
					$start && defined $self->_words_plugins->{start}->{$word}
						? ( 1 => $self->_words_plugins->{start}->{$word} )
						: $end && defined $self->_words_plugins->{end}->{$word}
							? ( 0 => $self->_words_plugins->{end}->{$word} )
							: defined $self->_words_plugins->{any}->{$word}
								? ( 1 => $self->_words_plugins->{any}->{$word} )
								: undef) {
			######################################################
				$self->trace("Got a hit with","'".$word."'","!", $begin ? "And it's just the beginning..." : "");
				#
				# $cnt is the specific position inside our flat array of
				# positions inside the query.
				#
				my $pos = $poses[$cnt];
				#
				# This for loop is only executed if for the specific word
				# that is triggered is having "more then one word" triggers
				# that are attached to it. In this case it iterates through
				# all those different combination and tries to match it
				# with the request of the query.
				#
				for my $word_count (sort { $b <=> $a } grep { $_ > 1 } keys %{$hitstruct}) {
				############################################################
					$self->trace( "Checking additional multiword triggers with length of", $word_count);
					my @sofar_words = @{$triggers{$pos}};
					for my $sofar_word (@sofar_words) {
						if (defined $hitstruct->{$word_count}->{$sofar_word}) {
							for (@{$hitstruct->{$word_count}->{$sofar_word}}) {
								$self->trace('Handle request matches:',ref $_,"'".$request->query_raw."'",$pos);
								push @results, $self->handle_request_matches($_,$request,$pos);
								return @results if $self->return_one && @results;
							}
						}
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
								if (defined $hitstruct->{$word_count}->{$new_next_word}) {
									for (@{$hitstruct->{$word_count}->{$new_next_word}}) {
										$self->trace('Handle request matches:',ref $_,"'".$request->query_raw."'",( $pos < $next_pos ) ? ( $pos,$next_pos ) : ( $next_pos,$pos ));
										push @results, $self->handle_request_matches($_,$request,( $pos < $next_pos ) ? ( $pos,$next_pos ) : ( $next_pos,$pos ));
										return @results if $self->return_one && @results;
									}
								}
								push @new_next_words, $new_next_word;
							}
						}
						push @sofar_words, @new_next_words;
					}
				}
				if (defined $hitstruct->{1}) {
					$self->trace('Handle request matches:',ref $_,"'".$request->query_raw."'",$poses[$cnt]);
					push @results, $self->handle_request_matches($_,$request,$poses[$cnt]) for @{$hitstruct->{1}};
					return @results if $self->return_one && @results;
				}
			} else {
				$self->trace("No hit with","'".$word."'");
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