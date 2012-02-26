package DDGTest::Goodie::WrongThree;

use DDG::Goodie;

words around => 'foo';

handle matches => sub { 'should anyway crash' };

1;