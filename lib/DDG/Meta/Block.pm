package DDG::Meta::Block;
# ABSTRACT: Inject keywords to make a L<DDG::Block::Blockable> plugin

use strict;
use warnings;
use Carp;
use DDG::Block::Blockable::Triggers;
use Package::Stash;
require Moo::Role;

=head1 DESCRIPTION


=method apply_keywords

Uses a given classname to install the described keywords.

It also adds the role L<DDG::Block::Blockable> to the target classname.

=cut

sub apply_keywords {
	my ( $class, $target ) = @_;

	#
	# triggers
	#

	my $triggers;
	my $stash = Package::Stash->new($target);

=keyword triggers_block_type

Gives back the block type for this plugin

=cut

	$stash->add_symbol('&triggers_block_type',sub { $triggers->block_type });

=keyword get_triggers



=cut

	$stash->add_symbol('&get_triggers',sub { $triggers->get });

=keyword has_triggers

Gives back if the plugin has triggers at all

=cut

	$stash->add_symbol('&has_triggers',sub { $triggers ? 1 : 0 });

=keyword triggers

Adds a new trigger. Possible parameter are block specific, so see
L<DDG::Block::Words> or L<DDG::Block::Regexp> for more informations.

=cut

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
