package DDG::Block::Blockable;
# ABSTRACT: Role for plugins that can go into a block

use Moo::Role;

requires qw(
	get_triggers
	has_triggers
	triggers_block_type
	triggers
);

=head1 DESCRIPTION

This role is for plugins that can go into a plugin. The required functions are
given via L<DDG::Meta::Block>, but can also be made in an own implementation.

The class using this role require B<get_triggers>, B<has_triggers>,
B<triggers_block_type> and B<triggers>.

Please lookup in L<DDG::Meta::Block> how you have to set them if you want to
make your own implementation.

=attr block

Every blockable plugin requires a block as attribute on creation.

=cut

has block => (
	is => 'ro',
	required => 1,
);

1;