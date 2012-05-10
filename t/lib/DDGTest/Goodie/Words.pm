package DDGTest::Goodie::Words;

use DDG::Goodie;

triggers startend => 'foo';

triggers start => 'bar', 'baz';
triggers start => 'buu';

triggers startend => 'foofoo';

triggers sub {
	start => [qw(abar abaz)],
};

triggers startend => sub { 'afoo', 'afoofoo' };

handle remainder => sub { shift; };

attribution
	email => 'god@universe.org',
	github => 'github';

1;