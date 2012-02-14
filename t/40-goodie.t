#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Goodie::Simple;
use DDGTest::Goodie::Regexp;

my $goodie = DDGTest::Goodie::Simple->new;

isa_ok($goodie,'DDGTest::Goodie::Simple');
ok($goodie->does('DDG::Goodie::Role'),'Checking DDGTest::Goodie::Simple does DDG::Goodie::Role');

is_deeply(DDGTest::Goodie::Simple->all_words_by_type,{
	around => [ "foo", "foofoo", "afoo", "afoofoo" ],
	before => [ "bar", "baz", "buu", "abar", "abaz" ],
},'Checking resulting all_words_by_type of DDGTest::Goodie::Simple',);

is_deeply([DDGTest::Goodie::Simple->all_regexps],[],'Checking DDGTest::Goodie::Simple has no regexps',);
ok(DDGTest::Goodie::Simple->has_words,'Checking DDGTest::Goodie::Simple has_words');

my $re = DDGTest::Goodie::Regexp->new;

isa_ok($re,'DDGTest::Goodie::Regexp');
ok($re->does('DDG::Goodie::Role'),'Checking DDGTest::Goodie::Regexp does DDG::Goodie::Role');

is_deeply([DDGTest::Goodie::Regexp->all_regexps],[qr{aregexp (.*)}, qr{bregexp (.*)}, qr{cregexp (.*)}],'Checking resulting all_regexps of DDGTest::Goodie::Regexp',);

is_deeply(DDGTest::Goodie::Regexp->all_words_by_type,{},'Checking DDGTest::Goodie::Regexp has no words',);
ok(!DDGTest::Goodie::Regexp->has_words,'Checking DDGTest::Goodie::Regexp not has_words');

done_testing;
