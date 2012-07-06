package DDG::HasAttribution;
# ABSTRACT: Role for a plugin that is able to give attribution informations

use Moo::Role;

requires qw(
	get_attributions
);

=head1 DESCRIPTION

This L<Moo::Role> is attached to plugins which are able to give attribution back. It
still can be an empty attribution.

The class using this role must implement a B<get_attributions> function which gives
back the attribution array.

For more information about the attributions see L<DDG::Meta::Attribution>.

=cut

1;
