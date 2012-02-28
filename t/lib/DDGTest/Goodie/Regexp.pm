package DDGTest::Goodie::Regexp;

use DDG::Goodie;

triggers qr/aregexp (.*)/i;

triggers qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i;

handle matches => sub { return join('|',@_) };

1;