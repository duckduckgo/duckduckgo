package DDGTest::Spice::Regexp;

use DDG::Spice;

triggers qr/aregexp (.*)/i;

triggers qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i;

handle matches => sub { return join('|',@_) };

1;