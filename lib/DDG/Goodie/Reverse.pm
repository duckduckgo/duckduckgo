package DDG::Goodie::Reverse;

use DDG::Goodie;

zci is_cached => 1;

words around => 'reverse';

handle remainder => sub { join('',reverse split(//,shift)) };

1;