package DDGTest::Goodie::ReBlockOne;

use DDG::Goodie;

regexp qr/regexp\s(.*)/i;

handle matches => sub { return join('|',@_) };

1;