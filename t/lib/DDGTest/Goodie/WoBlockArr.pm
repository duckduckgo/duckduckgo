package DDGTest::Goodie::WoBlockArr;

use DDG::Goodie;

triggers any => 'or';

handle query_parts => sub { join('|',@_) };

1;