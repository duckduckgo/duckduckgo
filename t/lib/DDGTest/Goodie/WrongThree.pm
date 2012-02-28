package DDGTest::Goodie::WrongThree;

use DDG::Goodie;

triggers startend => 'foo';

handle matches => sub { 'should anyway crash' };

1;