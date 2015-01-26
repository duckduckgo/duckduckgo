package DDGTest::Spice::MultiTriggerType;

use DDG::Spice;

triggers start => 'firstword secondword';
triggers end => 'secondword thirdword';
triggers any => 'firstword', 'thirdword';

handle remainder => sub { shift; };

1;