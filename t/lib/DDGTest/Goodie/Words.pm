package DDGTest::Goodie::Words;

use DDG::Goodie;

words around => 'foo';

words before => 'bar', 'baz';
words before => 'buu';

words around => 'foofoo';

words sub {
	before => [qw(abar abaz)],
};

words around => sub { 'afoo', 'afoofoo' };

handle remainder => sub { shift; };

1;