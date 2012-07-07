package DDGTest::Goodie::Location;

use DDG::Goodie;

triggers any => "my location";

handle sub { join(" ",$loc->country_name,$loc->region_name,$loc->city) };

1;