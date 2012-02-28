package DDGTest::Goodie::WrongFour;

use DDG::Goodie;

triggers query_nowhitespace_nodash => qr{(.*)};

handle remainder => sub { 'should anyway crash' };

1;