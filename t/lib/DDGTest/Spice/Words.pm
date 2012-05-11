package DDGTest::Spice::Words;

use DDG::Spice;

triggers startend => 'foo';

triggers start => 'bar', 'baz';
triggers start => 'buu';

triggers startend => 'foofoo';

triggers sub {
	start => [qw(abar abaz)],
};

triggers startend => sub { 'afoo', 'afoofoo' };

spice to => 'http://some.api/';

handle remainder => sub { shift; };

sub nginx_conf { "bla" }

attribution
	facebook => [ duckduckgo => 'DuckDuckGo' ],
	twitter => 'duckduckgo',
	email => [ 'hulk@avengers.com', 'Hulk of the Avengers' ];

1;