package DDG::Test::Fathead;
# ABSTRACT: Adds keywords to easily test Fathead plugins.

use strict;
use warnings;
use Carp;
use Test::More;
use DDG::Test::Block;
use DDG::Fathead;
use Package::Stash;

=head1 DESCRIPTION

Installs functions for testing Fatheads.

B<Warning>: Be aware that you only use this module inside your test files in B<t/>.

=cut

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;
	my $stash = Package::Stash->new($target);
}

1;
