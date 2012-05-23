package DDGTest::Goodie::WoBlockTwo;

use DDG::Goodie;

triggers any => 'two';

triggers start => 'how to do';
triggers end => 'for the win';
triggers any => 'black magic';

handle remainder => sub { $_ };

1;