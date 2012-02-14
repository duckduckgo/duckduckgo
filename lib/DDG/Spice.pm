package DDG::Spice;

use strict;
use warnings;
use Carp;
use DDG::Meta;
require Moo::Role;
require Moo;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	#
	# Applying DDG::Spice::Role
	#
	
	Moo::Role->apply_role_to_package($target,'DDG::Spice::Role');
	
	#
	# Make blockable
	#

	DDG::Meta->make_blockable($target);
	
	#
	# Import Data::Printer
	#
	
	#
	# let there be Moo!
	#

	goto &Moo::import;
}

1;