package DDG::Test::Goodie;

use strict;
use warnings;
use Carp;
use DDG::Request;
use DDG::ZeroClickInfo;
use Test::More;
use Class::Load ':all';
use DDG::Block::Words;
use DDG::Block::Regexp;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	{
		no strict "refs";

		my %zci_params;

		*{"${target}::test_zci"} = sub {
			my $answer = shift;
			ref $_[0] eq 'HASH' ? 
				DDG::ZeroClickInfo->new(%zci_params, %{$_[0]}, answer => $answer ) :
				DDG::ZeroClickInfo->new(%zci_params, @_, answer => $answer )
		};

		*{"${target}::zci"} = sub {
			if (ref $_[0] eq 'HASH') {
				for (keys %{$_[0]}) {
					$zci_params{$_} = $_[0]->{$_};
				}
			} else {
				while (@_) {
					my $key = shift;
					my $value = shift;
					$zci_params{$key} = $value;
				}
			}
		};

		*{"${target}::ddg_goodie_test"} = sub {
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
				my $zci = shift;
				my $request = DDG::Request->new({ query_raw => $query });
				my $answer = undef;
				( $answer ) = $words_block->request($request) if $words_block;
				( $answer ) = $words_block->request($request) if $regexp_block && !$answer;
				is_deeply($answer,$zci,'Testing query '.$query);
			}
		};
	}

}

1;