package DDGTest::Goodie::Regexp;

use DDG::Goodie;

regexp qr{aregexp (.*)};

regexp qr{bregexp (.*) (.*)}, qr{cregexp (.*)};

handle matches => sub { return join('||JOINED||',@_) };

1;