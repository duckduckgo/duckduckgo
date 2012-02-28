package DDGTest::Goodie::WrongTwo;

use DDG::Goodie;

triggers startend => 'foo';

triggers qr{(.*)};

handle sub { 'should anyway crash' };

1;