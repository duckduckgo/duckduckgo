package DDGTest::Goodie::Request;

use DDG::Goodie;

triggers any => "my request";

handle sub { $req->query_raw };

1;