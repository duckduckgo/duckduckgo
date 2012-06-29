package DDG::Spice;

use strict;
use warnings;
use Carp;
use DDG::Meta;
require Moo::Role;

=head1 DESCRIPTION

This is the Spice Meta class. It injects all the keywords used for ZeroClickInfo Spice.

=cut

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	#
	# Make base
	#

	DDG::Meta->apply_base_to_package($target);
	
	#
	# Apply keywords
	#

	DDG::Meta->apply_spice_keywords($target);
}

1;