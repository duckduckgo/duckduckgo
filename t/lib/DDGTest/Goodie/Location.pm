package DDGTest::Goodie::Location;

use DDG::Goodie;

triggers any => "my location";

handle sub { my $loc = $req->location; join(" ",$loc->country_name,$loc->region_name,$loc->city) };

1;