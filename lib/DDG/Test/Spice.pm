package DDG::Test::Spice;
# ABSTRACT: Adds keywords to easily test Spice plugins.

use strict;
use warnings;
use Carp;
use Test::More;
use DDG::Test::Block;
use DDG::ZeroClickInfo::Spice;
use Package::Stash;
use Class::Load 'load_class';

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
		my $query = shift;
		my $answer = shift;
		my $spice = shift;
		if ($answer) {
			is_deeply($answer,$spice,'Testing query '.$query);
		} else {
			fail('Expected result but dont get one on '.$query);
		}
	},@_)});

=keyword alt_to_test

Use this function to verify your spice's alt_to definitions:

	alt_to_test('DDG::Spice::My::Spice', [qw(alt1 alt2 alt3)]);

This would check for the following:

	callbacks 'ddg_spice_my_alt[123]'
	paths '/js/spice/my/alt[123]/'

=cut

	$stash->add_symbol('&alt_to_test', sub {
		my ($spice, $alt_tos) = @_;

		load_class($spice);

		my $rewrites = $spice->alt_rewrites;
		ok($rewrites, "$spice has rewrites");

		ok($spice =~ /^DDG::(.+)::/, "Extract base from $spice");
		my $base = $1;

		$base = lc $base;
		my $cb_base = $base;
		$cb_base =~ s/::/_/g;
		my $path_base = $base;
		$path_base =~ s|::|/|g;

		for my $alt (@$alt_tos){
			my $rw = $rewrites->{$alt};
			ok($rw, "$alt exists");
			ok($rw->callback eq "ddg_${cb_base}_$alt", "$alt callback");
			ok($rw->path eq "/js/$path_base/$alt/", "$alt path");
		}
	});
}

1;
