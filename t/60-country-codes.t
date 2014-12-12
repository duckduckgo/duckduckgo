#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::CountryCodes;

my $c = new DDG::CountryCodes();

# standards
is($c->country2code('Norway'), 'no');
is($c->country2code('Japan'),  'jp');
is($c->country2code('Japan', LOCALE_CODE_ALPHA_2), 'jp');
is($c->country2code('Japan', LOCALE_CODE_ALPHA_3), 'jpn');

is($c->code2country('no'), 'Norway');
is($c->code2country('jp'), 'Japan');
is($c->code2country('jpn'), undef);
is($c->code2country('jp',  LOCALE_CODE_ALPHA_2), 'Japan');
is($c->code2country('jpn', LOCALE_CODE_ALPHA_2), undef);
is($c->code2country('jp',  LOCALE_CODE_ALPHA_3), undef);
is($c->code2country('jpn', LOCALE_CODE_ALPHA_3), 'Japan');

# check some ddg local aliases
is($c->country2code('murica'),  'us');
is($c->country2code('America'), 'us');
is($c->country2code('murica',  LOCALE_CODE_ALPHA_2), 'us');
is($c->country2code('America', LOCALE_CODE_ALPHA_2), 'us');
is($c->country2code('murica',  LOCALE_CODE_ALPHA_3), 'usa');
is($c->country2code('America', LOCALE_CODE_ALPHA_3), 'usa');

# check some ddg renames
is($c->code2country('gb'), 'The United Kingdom');
is($c->code2country('kr'), 'The Republic of Korea');

done_testing;
