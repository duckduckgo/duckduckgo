package DDGTest::Goodie::WrongFour;

use DDG::Goodie;

regexp nowhitespaces_nodashes => qr{(.*)};

handle remainder => sub { 'should anyway crash' };

1;