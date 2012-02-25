package DDGTest::Goodie::ReBlockOne;

use DDG::Goodie;

regexp qr{regexp\s(.*)};

handle matches => sub { return join('|',@_) };

1;