package DDGTest::Goodie::Language;

use DDG::Goodie;

triggers any => "my language";

handle sub { join(" ",$lang->name_in_english,$lang->locale) };

1;