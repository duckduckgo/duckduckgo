package DDGTest::Goodie::WrongOne;

use DDG::Goodie;

handle sub { 'should anyway crash' };

words around => 'foo';

1;