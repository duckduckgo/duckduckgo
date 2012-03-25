package DDG::Test;

use strict;
use warnings;
use Carp;
use Test::More;
use Class::Load ':all';
use DDG::Request;
use DDG::Block::Words;
use DDG::Block::Regexp;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	{
		no strict "refs";

		*{"${target}::block_test"} = sub {
			my $result_callback = shift;
			my $plugins_ref = shift;
			my @plugins = @{$plugins_ref};
			my @regexp; my @words;
			for (@plugins) {
				load_class($_);
				if ($_->triggers_block_type eq 'Words') {
					push @words, $_;
				} elsif ($_->triggers_block_type eq 'Regexp') {
					push @regexp, $_;
				} else {
					croak "Unknown plugin type";
				}
			}
			my $words_block = @words ? DDG::Block::Words->new( plugins => [@words]) : undef;
			my $regexp_block = @regexp ? DDG::Block::Regexp->new( plugins => [@regexp]) : undef;
			while (@_) {
				my $query = shift;
				my $target = shift;
				my $request = DDG::Request->new({ query_raw => $query });
				my $answer = undef;
				( $answer ) = $words_block->request($request) if $words_block;
				( $answer ) = $regexp_block->request($request) if $regexp_block && !$answer;
				if ( defined $target ) {
					for ($answer) {
						$result_callback->($query,$answer,$target);
					}
				} else {
					is($answer,$target,'Checking for not matching on '.$query);
				}
			}
		}
	}
}

1;