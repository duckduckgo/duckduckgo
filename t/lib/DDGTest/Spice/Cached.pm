package DDGTest::Spice::Cached;

use DDG::Spice;

triggers any => "cached";

spice to => 'www.mywebsite.com/api/?q=$1';
spice is_cached => 1;

handle remainder => sub {
	return $_ if $_;
	return;
};

1;
