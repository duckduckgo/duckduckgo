package DDGTest::Goodie::CollideOne;

use DDG::Goodie;

triggers any => 'collide';

handle query_parts => sub { join('|',@_) };

1;