package DDG::Meta::ShareDir;

use strict;
use warnings;
use Carp;
use Module::Data;
use Path::Class;
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

	if ( -e $moddata->root->parent->subdir('lib') ) {
		return unless -e $moddata->root->parent->subdir('share'); 
		$share = dir($moddata->root->parent->subdir('share'),$share_path);
	} else {
		$share = dir(module_dir($target));
	}

	{
		no strict "refs";

		*{"${target}::module_share_dir"} = sub { dir('share',$share_path) };
		*{"${target}::share"} = sub {
			@_ ? -d dir($share,@_) ? $share->subdir(@_) : $share->file(@_) : $share
		};
	}

}

1;
