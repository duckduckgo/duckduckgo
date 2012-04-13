package DDG::Meta::Block;

use strict;
use warnings;
use Carp;
use DDG::Block::Blockable::Triggers;
use Package::Stash;

require Moo::Role;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	#
	# triggers
	#

	my $triggers;
	my $stash = Package::Stash->new($target);
	$stash->add_symbol('&triggers_block_type',sub { $triggers->block_type });
	$stash->add_symbol('&get_triggers',sub { $triggers->get });
	$stash->add_symbol('&has_triggers',sub { $triggers ? 1 : 0 });
	$stash->add_symbol('&triggers',sub {
		$triggers = DDG::Block::Blockable::Triggers->new unless $triggers;
		$triggers->add(@_)
	});

	#
	# apply role
	#

	Moo::Role->apply_role_to_package($target,'DDG::Block::Blockable');

}

1;
