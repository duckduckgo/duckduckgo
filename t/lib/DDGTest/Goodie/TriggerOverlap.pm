package DDGTest::Goodie::TriggerOverlap;

use DDG::Goodie;

triggers start => 'myTrigger start';
triggers end => 'end myTrigger';
triggers any => 'myTrigger';
# triggers startend => 'myTrigger', 'myTrigger startend';

handle remainder => sub { $_ };

1;