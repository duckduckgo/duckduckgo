package DDGTest::Goodie::WoBlockThree;

use DDG::Goodie;

triggers any => 'three';

handle query => sub { $_ };

1;