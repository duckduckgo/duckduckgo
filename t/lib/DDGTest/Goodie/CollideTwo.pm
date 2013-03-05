package DDGTest::Goodie::CollideTwo;

use DDG::Goodie;

triggers any => 'collide';

handle query_parts => sub { join('|',@_) };

1;