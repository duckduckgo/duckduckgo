package DDGTest::Goodie::RequireExampleQueries;

use DDG::Goodie;

zci 'answer_type' => 'goodie_example_queries';

primary_example_queries   "first trigger a", "second trigger b";
secondary_example_queries "second trigger c", "first trigger d";

triggers startend => 'first trigger', 'second trigger';

handle remainder => sub { shift };

1;
