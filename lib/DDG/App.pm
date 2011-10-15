package DDG::App;

use Moose;

with qw(
	MooseX::Getopt
);

sub error { die "[".(ref shift)."] ".shift }

1;