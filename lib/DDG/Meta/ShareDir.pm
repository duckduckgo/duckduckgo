package DDG::Meta::ShareDir;

use strict;
use warnings;
use Carp qw( croak );
use Module::Data;
use Path::Class;
use Package::Stash;
use File::ShareDir ':ALL';

require Moo::Role;

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	return if exists $applied{$target};
	$applied{$target} = undef;

	my @parts = split('::',$target);
	shift @parts;
	unshift @parts, 'share';
	my $share_path = join('/',map { s/([a-z])([A-Z])/$1_$2/; lc; } @parts);

	my $moddata = Module::Data->new($target);
	my $basedir = $moddata->root->parent;

	my $share;

	# kent\n: If the module was found in $root/t/lib/,
	# we need to go up another level, as $basedir needs to be $root,
	# not $root/t
	if ( -e $basedir->parent->subdir('t') ) {
		$basedir = $basedir->parent;
	}

	if ( -e $basedir->subdir('lib') and -e $basedir->subdir('share') ) {
		my $dir = dir($basedir,$share_path);
		$share = $dir if -d $dir;
	} else {
		my $dir = module_dir($target);
		$share = dir($dir) if -d $dir;
	}

	if ($share) {
		my $stash = Package::Stash->new($target);
		$stash->add_symbol('&module_share_dir', sub { $share_path });
		$stash->add_symbol('&share', sub {
			@_ ? -d dir($share,@_)
				? $share->subdir(@_)
				: $share->file(@_)
			: $share
		});

		#
		# apply role
		#

		Moo::Role->apply_role_to_package($target,'DDG::HasShareDir');
	}

}

1;
