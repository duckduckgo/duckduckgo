package DDG::Plugin::Sample::Hash;

use Moo;
with qw( DDG::Plugin );

sub triggers { qw( bla blub ) }

sub simple_query { shift; __PACKAGE__ }

1;