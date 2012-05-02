package DDGTest::Spice::Words;

use DDG::Spice;

triggers startend => 'foo';

triggers start => 'bar', 'baz';
triggers start => 'buu';

triggers startend => 'foofoo';

triggers sub {
	start => [qw(abar abaz)],
};

triggers startend => sub { 'afoo', 'afoofoo' };

handle remainder => sub { shift; };

sub nginx_conf { "bla" }

1;