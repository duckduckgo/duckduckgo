package DDG::Test::Spice;

use strict;
use warnings;
use Carp;
use Test::More;
use DDG::Test;
use DDG::ZeroClickInfo::Spice;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	{
		no strict "refs";

		my %spice_params;

		*{"${target}::test_spice"} = sub {
			my $call = shift;
			ref $_[0] eq 'HASH' ? 
				DDG::ZeroClickInfo::Spice->new(%spice_params, %{$_[0]}, call => $call ) :
				DDG::ZeroClickInfo::Spice->new(%spice_params, @_, call => $call )
		};

		*{"${target}::spice"} = sub {
			if (ref $_[0] eq 'HASH') {
				for (keys %{$_[0]}) {
					$spice_params{$_} = $_[0]->{$_};
				}
			} else {
				while (@_) {
					my $key = shift;
					my $value = shift;
					$spice_params{$key} = $value;
				}
			}
		};

		*{"${target}::ddg_spice_test"} = sub { block_test(sub {
			my $query = shift;
			my $answer = shift;
			my $spice = shift;
			if ($answer) {
				is_deeply($answer,$spice,'Testing query '.$query);
			} else {
				fail('Expected result but dont get one on '.$query);
			}
		},@_)};
	}

}

1;