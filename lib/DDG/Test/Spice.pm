package DDG::Test::Spice;
# ABSTRACT: Adds keywords to easily test Spice plugins.

use strict;
use warnings;
use Carp;
use Test::More;
use DDG::Test::Block;
use DDG::ZeroClickInfo::Spice;
use Package::Stash;

=head1 DESCRIPTION

Installs functions for testing Spice.

B<Warning>: Be aware that you only use this module inside your test files in B<t/>.

=cut

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;
	my $stash = Package::Stash->new($target);

=keyword test_spice

Easy function to generate a L<DDG::ZeroClickInfo::Spice> for the test. See
L</ddg_spice_test>.

You can predefine parameters via L</spice>.

The first parameter gets treated as the
L<call of the DDG::ZeroClickInfo::Spice|DDG::ZeroClickInfo::Spice/call>

=cut

	my %spice_params = (
		call_type => 'include',
	);

	$stash->add_symbol('&test_spice', sub {
		my $call = shift;
		ref $_[0] eq 'HASH'
			? DDG::ZeroClickInfo::Spice->new(%spice_params, %{$_[0]}, call => $call )
			: DDG::ZeroClickInfo::Spice->new(%spice_params, @_, call => $call )
	});

=keyword spice

You can predefine L<DDG::ZeroClickInfo::Spice> parameters for usage in
L</test_spice>.

This function can be used several times to change specific defaults on the
fly.

=cut

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

=keyword ddg_spice_test

With this function you can easily generate a small own L<DDG::Block> for
testing your L<DDG::Spice> alone or in combination with others.

  ddg_spice_test(
    [qw( DDG::Spice::MySpice )],
    'myspice data' => test_spice('/js/spice/my_spice/data'),
    'myspice data2' => test_spice('/js/spice/my_spice/data2'),
  );

=cut

	$stash->add_symbol('&ddg_spice_test', sub { block_test(sub {
		my ($query, $answer, $spice) = @_;

		if ($answer) {
			if (ref $spice->{call} eq 'Regexp') {
				like($answer->{call}, $spice->{call}, 'Regexp: ' . $spice->{call} );
				$spice->{call} = $answer->{call};
			}

			is_deeply($answer,$spice,'Testing query '.$query);
		} else {
			fail('Expected result but dont get one on '.$query);
		}
	},@_)});

}

1;
