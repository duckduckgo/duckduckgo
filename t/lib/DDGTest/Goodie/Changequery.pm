package DDGTest::Goodie::Changequery;

#
# Evil case of a plugin that somehow modifies the query on working with it
#

use DDG::Goodie;

triggers startend => 'duckduckgo','ios';

# list of trigger words
my $words = 'ios';

handle query_raw => sub {
	if (m/$words/i){
		my $query = $_;
		s/$words//ig;
		return $query if length $_ > 1;
	}
	return;
};

1;