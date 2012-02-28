package DDGTest::Goodie::WrongOne;

use DDG::Goodie;

handle sub { 'should anyway crash' };

triggers startend => 'foo';

1;