package DDGTest::Spice::ChangeCached;

use DDG::Spice;

triggers any => 'changed caching';

spice to => 'www.mywebsite.com/api/?q=$1';

spice is_cached => 0;

handle remainder => sub {
	
	return $_, {is_cached => 1} if $_ eq "test";
	return $_ if $_;
	return;
};

1;
