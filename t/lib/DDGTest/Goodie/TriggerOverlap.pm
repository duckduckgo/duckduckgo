package DDGTest::Goodie::TriggerOverlap;

use DDG::Goodie;

triggers start => 'myTrigger', 'myTrigger start';
triggers end => 'myTrigger', 'end myTrigger';
triggers any => 'myTrigger';
# triggers startend => 'myTrigger', 'myTrigger startend';

handle remainder => sub { $_ };

1;