package DDGTest::Goodie::Simple;

use DDG::Goodie;

words around => 'foo';

words before => 'bar', 'baz';
words before => 'buu';

words around => 'foofoo';

words sub {
	before => [qw(abar abaz)],
};

words around => sub { 'afoo', 'afoofoo' };

handle remainder => sub { @_ };

1;