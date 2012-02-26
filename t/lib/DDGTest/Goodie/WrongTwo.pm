package DDGTest::Goodie::WrongTwo;

use DDG::Goodie;

words around => 'foo';

regexp qr{(.*)};

handle sub { 'should anyway crash' };

1;