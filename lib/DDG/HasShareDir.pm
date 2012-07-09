package DDG::HasShareDir;
# ABSTRACT: Role for a plugin that has a share directory

use Moo::Role;

requires qw(
	module_share_dir
	share
);

=head1 DESCRIPTION

This L<Moo::Role> is attached to plugins which are able to give sharedir
informations. A class which has no sharedir is not allowed to carry this role.

The class using this role must implement B<module_share_dir> and B<share>.

B<module_share_dir> must return the path to the sharedir inside the repo,
like B<share/goodie/public_dns>.

B<share> must give back a L<Path::Class::Dir> of the share directory if its
called without parameter. If a parameter is given it must give back
L<Path::Class::File> or L<Path::Class::Dir> of the corresponding file in the
sharedir that is given as parameter. Checkout L<DDG::Meta::ShareDir/share> for
information about usage of this function.

For more information about the sharedir see L<DDG::Meta::ShareDir>.

=head1 SEE ALSO

L<Dist::Zilla::Plugin::AutoModuleShareDirs>

=cut

1;