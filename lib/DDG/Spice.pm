package DDG::Spice;

use strict;
use warnings;
use Carp;
use DDG::Meta;
require Moo::Role;

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