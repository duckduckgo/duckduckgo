package DDGTest::Goodie::WoBlockBang;
# Just a test not actual Bang implementation

use DDG::Goodie;

triggers any =>
	'!wikipedia',
	'!yahoo',
	'!bang';

handle remainder => sub { $_ };

1;