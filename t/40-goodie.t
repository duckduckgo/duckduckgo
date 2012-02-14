#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Goodie::Simple;

my $goodie = DDGTest::Goodie::Simple->new;

isa_ok($goodie,'DDGTest::Goodie::Simple');
ok($goodie->does('DDG::Goodie::Role'),'DDGTest::Goodie::Simple');

is_deeply(DDGTest::Goodie::Simple->all_words_by_type,{
	around => [ "foo", "foofoo", "afoo", "afoofoo" ],
	before => [ "bar", "baz", "buu", "abar", "abaz" ],
},'Checking resulting all_words of DDGTest::Goodie::Simple',);

done_testing;
