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

	my $share;

	my $basedir = $moddata->root->parent;

	if ( -e $basedir->subdir('lib') and -e $basedir->subdir('share') ) {
		$share = dir($basedir->subdir('share'),$share_path);
	} else {
		$share = dir(module_dir($target));
	}

	my $stash = Package::Stash->new($target);
	$stash->add_symbol('&module_share_dir', sub { dir('share',$share_path) });
	$stash->add_symbol('&share', sub {
			@_ ? -d dir($share,@_) ? $share->subdir(@_) : $share->file(@_) : $share
	});
}

1;
