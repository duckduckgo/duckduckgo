package DDG::HasShareDir;

use Moo::Role;

requires qw(
	module_share_dir
	share
);

1;