package DDGTest::Goodie::ReBlockOne;

use DDG::Goodie;

triggers qr/regexp\s(.*)/i;

handle matches => sub { return join('|',@_) };

1;