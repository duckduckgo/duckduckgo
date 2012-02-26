package DDGTest::Goodie::Regexp;

use DDG::Goodie;

regexp qr/aregexp (.*)/i;

regexp qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i;

handle matches => sub { return join('||JOINED||',@_) };

1;