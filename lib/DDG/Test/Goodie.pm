package DDG::Test::Goodie;

use strict;
use warnings;
use Carp;
use Test::More;
use DDG::Test::Block;
use DDG::ZeroClickInfo;
use Package::Stash;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;
	my $stash = Package::Stash->new($target);

	my %zci_params;

	$stash->add_symbol('&test_zci', sub {
		my $answer = shift;
		ref $_[0] eq 'HASH' ? 
			DDG::ZeroClickInfo->new(%zci_params, %{$_[0]}, answer => $answer ) :
			DDG::ZeroClickInfo->new(%zci_params, @_, answer => $answer )
	});

	$stash->add_symbol('&zci', sub {
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
	});

	$stash->add_symbol('&ddg_goodie_test', sub { block_test(sub {
			my $query = shift;
			my $answer = shift;
			my $zci = shift;
			if ($answer) {
				fail('Doesnt expected result but get one on '.$query) unless defined $zci;
				if (ref $zci->answer eq 'Regexp') {
					like($answer->answer,$zci->answer,'Regexp check against text for '.$query);
					$zci->{answer} = $answer->answer;
				}
				if (ref $zci->html eq 'Regexp') {
					like($answer->html,$zci->html,'Regexp check against html for '.$query);
					$zci->{html} = $answer->html;
				}
				is_deeply($answer,$zci,'Testing query '.$query);
			} else {
				fail('Expected result but dont get one on '.$query) unless defined $answer;
			}
		},@_)
	});

}

1;