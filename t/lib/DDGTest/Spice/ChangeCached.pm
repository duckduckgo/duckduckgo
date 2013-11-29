package DDGTest::Spice::ChangeCached;

use DDG::Spice;

triggers any => 'changed caching';

spice to => 'www.mywebsite.com/api/?q=$1';
spice is_cached => 0;

handle remainder => sub {
	
	if ($_) {
		spice is_cached => $_ eq "test" ? 1 : 0;
		return $_;
	}
	return;
};

1;
