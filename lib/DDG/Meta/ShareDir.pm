package DDG::Meta::ShareDir;
# ABSTRACT: Installing functions for easy access to the module sharedir

use strict;
use warnings;
use Carp qw( croak );
use Module::Data;
use Path::Class;
use Package::Stash;
use File::ShareDir ':ALL';

require Moo::Role;

=head1 DESCRIPTION

This package installs the function required for using a sharedir and also
provides the function L<share> for easy access to it.

B<Warning>: This function only installs its function when there is a sharedir
at the proper directory inside the repository, else it will fail. You cant
define that directory for yourself, the complete concept requires staying to
the convention, see L</module_share_dir>.

=method apply_keywords

Uses a given classname to install the described keywords.

It also adds the role L<DDG::HasShareDir> to the target classname if the
class has a sharedir.

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my @parts = split('::',$target);
	shift @parts;
	unshift @parts, 'share';
	my $share_path = join('/',map { s/([a-z])([A-Z])/$1_$2/g; lc; } @parts);

	my $moddata = Module::Data->new($target);
	my $basedir = $moddata->root->parent;

	my $share;

	# kent\n:
	# If the module we are currently running setup for is presently in t/lib/
	# such as "t/lib/Test/Frob.pm", then asking "Where it came from, where is
	# the root", would resolve as "t/lib/".
	#
	# This poses a problem, as normally, the module is in lib/ during dev, and
	# its sharedir is in share/.
	#
	# This would mean if a library was in t/lib/ , it would try to detect the
	# presence of t/share to determine if it was a "dev environment" or not,
	# and not find that dir, and falsely conclude the library in t/lib/ was
	# installed, which will never be the case.
	#
	# Hence, we detect the special case of "t/lib" and ascend another level to
	# find the "project root", and the presensce of "share" at the project root
	# indicates its a dev environment, and everything works as expected.
	#
	# Simplifed in pseudocode:
	#
	# X->setup
	# 	a = path of X;
	# 	b = "base dir" of a,
	# 		ie: $root/t/lib/X.pm -> $root/t
	# 		    $root/lib/Y.pm   -> $root
	#
	# 	is there a path $b/../t ?
	# 		$b = "$root/t"   -> $root/t/../t  -> $root/t/ --> yes
	# 		$b = "$root"     -> $root/../t                --> no
	#
	#	yes:
	#		$b = $b/../
	#			 -> $b = "$root/t/../"
	#			 -> $b = "$root"
	#
	# Noting of course, we don't know what "$root" is, and this codes purpose
	# is to find the value of $root.
	#
	if ( -e $basedir->parent->subdir('t') ) {
		$basedir = $basedir->parent;
	}

	if ( -e $basedir->subdir('lib') and -e $basedir->subdir('share') ) {
		my $dir = dir($basedir,$share_path);
		$share = $dir if -d $dir;
	} else {
		eval {
			my $dir = module_dir($target);
			$share = dir($dir) if -d $dir;
		}
	}

	if ($share) {
		my $stash = Package::Stash->new($target);

=keyword share

This function gives direct access to sharedir content. For example with

  my $file = share('somefile.txt');

you will get a L<Path::Class::File> object of this specific file inside
your sharedir. It works in development and inside the live system after
installation of the module.

=cut

		$stash->add_symbol('&share', sub {
			@_ ? -d dir($share,@_)
				? $share->subdir(@_)
				: $share->file(@_)
			: $share
		});

=keyword module_share_dir

This function gets installed as part of the requirements a sharedir must
provide. It gives back the path inside the repository where the sharedir
of this module is placed. B<DDG::Spice::TestTest> gets to
B<share/spice/test_test>.

=cut

		$stash->add_symbol('&module_share_dir', sub { $share_path });

=keyword with_style_css

This function gets installed if the sharedir contains F</style.css>.
It will concatenate its arguments with the contents of that file to
provide a convenient and consistent mechanism to style HTML output.

=cut

        if (-e $share->file('style.css')) {
            my $css = $share->file('style.css')->slurp;
            $stash->add_symbol('&with_style_css', sub { join('', $css, @_); });
        }

		#
		# apply role
		#

		Moo::Role->apply_role_to_package($target,'DDG::HasShareDir');
	}

}

1;
