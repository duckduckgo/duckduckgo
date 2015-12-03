package DDGTest::Spice::AltTo;

use DDG::Spice;

triggers start => 'alt_to';

spice to => 'https://duckduckgo.com/alt_to.js?q=$1&callback={{callback}}';

spice alt_to => {
	alt1 => { to => 'https://duckduckgo.com/alt1.js?q=$1&callback={{callback}}' },
	alt2 => { to => 'https://duckduckgo.com/alt2.js?q=$1&callback={{callback}}' }
};

handle remainder => sub { return $_ };

1;
