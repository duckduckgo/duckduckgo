package DDGTest::Goodie::TriggerOverlap;

use DDG::Goodie;

triggers start => 'mytrigger start';
triggers end => 'end mytrigger';
triggers any => 'mytrigger';
# triggers startend => 'mytrigger', 'mytrigger startend';

handle remainder => sub { $_ };

1;