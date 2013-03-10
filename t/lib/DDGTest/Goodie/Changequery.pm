package DDGTest::Goodie::Changequery;

#
# Evil case of a plugin that somehow modifies the query on working with it
#

use DDG::Goodie;

triggers startend => 'duckduckgo','ios';

handle query_raw => sub {
	s/.+//ig;
};

1;