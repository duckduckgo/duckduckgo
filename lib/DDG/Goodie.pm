package DDG::Goodie;

use strict;
use warnings;
use Carp;
use DDG::Meta;
require Moo::Role;

=head1 DESCRIPTION

This is the Goodie Meta class. It injects all the keywords used for ZeroClickInfo Goodies.

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

	DDG::Meta->apply_goodie_keywords($target);
	
}

1;