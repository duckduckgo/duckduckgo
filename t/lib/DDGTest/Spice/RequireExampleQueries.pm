package DDGTest::Spice::RequireExampleQueries;

use DDG::Spice;

#zci 'answer_type' => 'spice_example_queries';

primary_example_queries   "first trigger a", "second trigger b";
secondary_example_queries "second trigger c", "first trigger d";
spice to => 'http://some.api/';

triggers startend => 'first trigger', 'second trigger';

handle remainder => sub { shift };

1;
