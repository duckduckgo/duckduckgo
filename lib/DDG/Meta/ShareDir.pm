package DDG::Meta::ShareDir;

use strict;
use warnings;
use Carp;
use Module::Data;
use Path::Class;
use Package::Stash;
use File::ShareDir ':ALL';

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	return if exists $applied{$target};
	$applied{$target} = undef;

	my @parts = split('::',$target);
	shift @parts;
	my $share_path = join('/',map { s/([a-z])([A-Z])/$1_$2/; lc; } @parts);

	my $moddata = Module::Data->new($target);

	# If the module was found in $root/t/lib/,
	# we need to go up another level, as $basedir needs to be $root,
	# not $root/t
	my $share;
	my $share_code = sub {

		my $basedir = $moddata->root->parent;

		if ( -e $basedir->parent->subdir('t') ) {
			$basedir = $basedir->parent;
		}

		if ( -e $basedir->subdir('lib') and -e $basedir->subdir('share') ) {
			return dir($basedir->subdir('share'),$share_path);
		} else {
			return dir(module_dir($target));
		}

	};

	my $stash = Package::Stash->new($target);
	$stash->add_symbol('&module_share_dir', sub { dir('share',$share_path) });
	$stash->add_symbol('&share', sub {
			$share = $share_code->() unless defined $share;
			@_ ? -d dir($share,@_)
				? $share->subdir(@_)
				: $share->file(@_)
			: $share
	});
}

1;
