package DDGTest::Spice::Data;

use DDG::Spice;

triggers qr/data (.*)/i;

spice to => 'http://some.other.api/';

handle matches => sub { return $_[0], data( key => 'value' ), data( otherkey => 'value' ), data ( key => 'finalvalue') };

1;