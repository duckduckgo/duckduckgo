package DDGTest::Goodie::WoBlockOne;

use DDG::Goodie;

triggers startend => 'around';

triggers start => 'before';

triggers end => 'after';

handle remainder => sub { $_ };

1;