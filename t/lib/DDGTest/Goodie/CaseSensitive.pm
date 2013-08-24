package DDGTest::Goodie::CaseSensitive;

use DDG::Goodie;

triggers any => 'notCaseSensitive', 'ALLCAPS';

handle remainder => sub { $_) };

1;