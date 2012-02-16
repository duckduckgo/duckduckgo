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
	# Make base
	#

	DDG::Meta->apply_base_to_package($target);
	
	#
	# Applying DDG::Spice::Role
	#
	
	Moo::Role->apply_role_to_package($target,'DDG::Spice::Role');
	Moo::Role->apply_role_to_package($target,'DDG::ZeroClickInfo::Role::Block');

	#
	# Apply keywords
	#

	DDG::Meta->apply_zci_keywords($target);
	DDG::Meta->apply_block_keywords($target);
	DDG::Meta->apply_spice_keywords($target);
}

1;