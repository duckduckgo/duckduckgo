#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib $FindBin::Dir . "/../lib";

use 5.010;

use DDG::Util::Translate;

#
# you need the generated po files, made by script/ddgc_pogenerator.pl from the community-platform repo
#

l_add_context('duckduckgo-results','po-files/duckduckgo-results');
l_add_context('test-context','po-files/test-context');

l_set_locales('de_DE');

l_set_context('test-context');

say l('Hello %1','stranger');
say l('You are %1 from %2','german','germany');

l_set_locales('ru_RU');

say l('Hello %1','stranger');
say l('You are %1 from %2','russian','russia');

l_set_context('duckduckgo-results');

say l('try');

# ------------------------------

say l('Hello %1','stranger');
