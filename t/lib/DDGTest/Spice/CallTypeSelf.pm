package DDGTest::Spice::CallTypeSelf;

use strict;
use DDG::Spice;

spice call_type => 'self';

triggers start => 'call type self';

handle remainder => sub {
	return $_ if $_;
	return;
};

1;