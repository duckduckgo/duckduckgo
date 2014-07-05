package DDGTest::Goodie::WordsWithEmptyShare;

use DDG::Goodie;

triggers startend => 'foo';

handle remainder => sub { my $in = shift; return ($in, html => with_style_css($in)); };

attribution
  email  => 'god@universe.org',
  github => 'github';

1;
