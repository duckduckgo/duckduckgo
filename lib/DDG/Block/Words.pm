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

The BUILD function is used to build a hash which maps trigger positions (start, any, end)
to trigger words to trigger phrase length to plugins.

Eg. Given triggers:

	START: "khan", "khan academy";
	ANY  : "forecast", "weather forecast";
	END  : "video", "youtube videos";

This would produce the following hash:

_words_plugins = {

	start => {

		'khan' => {
			1 => [ DDG::Spice::KhanAcademy ],
			2 => {
				'khan academy' => [ DDG::Spice::KhanAcademy ]
			}
		}
	},

	any => {

		'forecast' => {
			1 => [ DDG::Spice::Forecast, DDG::Spice::Foo ]
		},

		'weather' => {
			2 => {
				'weather forecast' => [ DDG::Spice::Forecast ]
			}
		}
	},

	end => {

		'video' => {
			1 => [ DDG::Spice::Video ]
		},

		'videos' => {
			2 => {
				'youtube videos' => [ DDG::Spice::Video ]
			}
		}
	}
}

=cut

sub _set_start_word_plugin { shift->_set_beginword_word_plugin('start',@_) }
sub _set_any_word_plugin { shift->_set_beginword_word_plugin('any',@_) }
sub _set_end_word_plugin { shift->_set_endword_word_plugin('end',@_) }

# Grab trigger word (or FIRST word from trigger phrase)
# to use as hash key for `start` and `any` trigger hashes
sub _set_endword_word_plugin {
	my ( $self, $type, $word, $plugin ) = @_;
	my @words = split(/\s+/,$word);
	$word = join(' ',@words);
	$self->_set_word_plugin($type,pop @words,$word,$plugin);
}

# Grab trigger word (or LAST word from trigger phrase)
# to use as hash key for `end` trigger hash
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
	#
	# Mapping positions of keywords in the request
	# to a flat array which access stepwise.
	#
	# @poses is an array of the positions inside
	# the triggers hash.
	#
	################################################
	my %triggers = %{$request->triggers};
	my $max = scalar keys %triggers;
	my @poses = sort { $a <=> $b } keys %triggers;
	$self->trace( "Trigger word positions: ", @poses );
	for my $cnt (0..$max-1) {
		#
		# Split into a flat array so we can easily
		# determine if the query is starting, ending
		# or still in the beginning, this is very essential
		# for the following steps.
		#
		my $start = $cnt == 0 ? 1 : 0;
		my $end = $cnt == $max-1 ? 1 : 0;

		# Iterate over each word in the query, checking if any of
		# the IA's have this specific word as (part of) a `start`,
		# `end` or `any` trigger.
		for my $word (@{$request->triggers->{$poses[$cnt]}}) {
			$self->trace( "Testing word:", "'".$word."'" );

			my @hits = ();
			{

				# Flag that tells us if there could be more words
				# after the matched word.
				#
				# Used for `any` and `start` triggers. Not for `end`
				# triggers because they look in-front of the word.
				my $begin = 0;

				# A hash containing all triggers related to the current word
				# 
				# The keys inside the hitstruct define the word count for the
				# trigger word/phrase. This is used to determine if the query
				# is long enough to have a match.
				# ie. a 2 word query can't match a 3 word trigger phrase
				my $hitstruct = undef;

				my $is_start = $start && defined $self->_words_plugins->{start}->{$word};
				my $is_end = $end && defined $self->_words_plugins->{end}->{$word};
				my $is_any = defined $self->_words_plugins->{any}->{$word};

				if ($is_start) {
					$begin = 1;
					$hitstruct = $self->_words_plugins->{start}->{$word};
					push(@hits,[$begin,$hitstruct]);
				}

				if ($is_end) {
					$begin = 0;
					$hitstruct = $self->_words_plugins->{end}->{$word};
					push(@hits,[$begin,$hitstruct]);
				}

				if ($is_any) {
					$begin = 1;
					$hitstruct = $self->_words_plugins->{any}->{$word};
					push(@hits,[$begin,$hitstruct]);
				}
			}

			# iterate over each type of trigger match for the current word
			# this allows us to consider multiple `start`, `end` and `any`
			# triggers for the current word
			while (my $hitref = shift @hits) {

				my ($begin,$hitstruct) = @{$hitref};
				######################################################
				$self->trace("Got a hit with","'".$word."'","!", $begin ? "And it's just the beginning..." : "");

				# $cnt is the specific position inside our flat array of
				# positions inside the query.
				my $pos = $poses[$cnt];

				# This `for` loop is only executed if we have a partial
				# match on a trigger phrase i.e. the first word in a `start`
				# or `any` trigger phrase, or the last word in an `end`
				# trigger phrase. In this case it iterates through all
				# those different combination and tries to match it
				# with the request of the query.
				#
				for my $word_count (sort { $b <=> $a } grep { $_ > 1 } keys %{$hitstruct}) {
				############################################################
					$self->trace( "Checking additional multiword triggers with length of", $word_count);
					my @sofar_words = @{$triggers{$pos}};
					for my $sofar_word (@sofar_words) {
						if (defined $hitstruct->{$word_count}->{$sofar_word}) {
							for (@{$hitstruct->{$word_count}->{$sofar_word}}) {
								push @results, $self->handle_request_matches($_,$request,$pos);
								if ($self->return_one && @results) {
									$self->trace("Got return_one and ".(scalar @results)." results, finishing here");
									return @results;
								}
							}
						}
					}
					# Here we take the index of the partially matched trigger phrase and
					# calculate where the trigger should start or end (based on whether 
					# it's a `start` or `end` trigger) to verify if the partial match is a
					# full match against the whole trigger
					#
					# Then we check if the next/previous word in the string matches
					# the next/previous word in the trigger phrase (again, based on whether it's a start or end trigger)
					my @next_poses_key = grep { $_ >= 0 } $begin ? ($cnt+1)..($cnt+$word_count-1) : ($cnt-$word_count+1)..($cnt-1);
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
										push @results, $self->handle_request_matches($_,$request,( $pos < $next_pos ) ? ( $pos,$next_pos ) : ( $next_pos,$pos ));
										if ($self->return_one && @results) {
											$self->trace("Got return_one and ".(scalar @results)." results, finishing here");
											return @results;
										}
									}
								}
								push @new_next_words, $new_next_word;
							}
						}
						push @sofar_words, @new_next_words;
					}
				}

				# Check if we have match on a single trigger word
				if (defined $hitstruct->{1}) {
					for (@{$hitstruct->{1}}) {
						push @results, $self->handle_request_matches($_,$request,$poses[$cnt]);
						if ($self->return_one && @results) {
							$self->trace("Got return_one and ".(scalar @results)." results, finishing here");
							return @results;
						}
					}
				}
			}
			$self->trace("No hit with","'".$word."'");
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