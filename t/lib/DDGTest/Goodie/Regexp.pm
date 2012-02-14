package DDGTest::Goodie::Regexp;

use DDG::Goodie;

regexp qr{aregexp (.*)};

regexp qr{bregexp (.*)}, qr{cregexp (.*)};

1;