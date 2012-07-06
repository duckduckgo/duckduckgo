package DDG::Test::Spice;
# ABSTRACT: Adds keywords to easily test Spice plugins.

use strict;
use warnings;
use Carp;
use Test::More;
use DDG::Test;
use DDG::ZeroClickInfo::Spice;
use Package::Stash;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;
	my $stash = Package::Stash->new($target);

	my %spice_params;

	$stash->add_symbol('&test_spice', sub {
		my $call = shift;
		ref $_[0] eq 'HASH'
			? DDG::ZeroClickInfo::Spice->new(%spice_params, %{$_[0]}, call => $call )
			: DDG::ZeroClickInfo::Spice->new(%spice_params, @_, call => $call )
	});

	$stash->add_symbol('&spice', sub {
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
	});

	$stash->add_symbol('&ddg_spice_test', sub { block_test(sub {
		my $query = shift;
		my $answer = shift;
		my $spice = shift;
		if ($answer) {
			is_deeply($answer,$spice,'Testing query '.$query);
		} else {
			fail('Expected result but dont get one on '.$query);
		}
	},@_)});

}

1;