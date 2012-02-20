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

is_deeply(DDGTest::Goodie::Simple->all_regexps_by_type,{},'Checking DDGTest::Goodie::Simple has no regexps',);
ok(DDGTest::Goodie::Simple->has_words,'Checking DDGTest::Goodie::Simple has_words');

my $re = DDGTest::Goodie::Regexp->new;

isa_ok($re,'DDGTest::Goodie::Regexp');
ok($re->does('DDG::Goodie::Role'),'Checking DDGTest::Goodie::Regexp does DDG::Goodie::Role');

is_deeply(DDGTest::Goodie::Regexp->all_regexps_by_type,{
	lc_query => [qr{aregexp (.*)}, qr{bregexp (.*) (.*)}, qr{cregexp (.*)}]
},'Checking resulting all_regexps_by_type of DDGTest::Goodie::Regexp',);

is_deeply(DDGTest::Goodie::Regexp->all_words_by_type,{},'Checking DDGTest::Goodie::Regexp has no words',);
ok(!DDGTest::Goodie::Regexp->has_words,'Checking DDGTest::Goodie::Regexp not has_words');

eval q{
	use DDGTest::Goodie::WrongOne;
};
like($@, qr/Please define words or regexp before you define a handler/, 'Checking DDGTest::Goodie::WrongOne for crashing proper');

eval q{
	use DDGTest::Goodie::WrongTwo;
};
like($@, qr/you can only do regexp or words/, 'Checking DDGTest::Goodie::WrongTwo for crashing proper');

eval q{
	use DDGTest::Goodie::WrongThree;
};
like($@, qr/You must be using regexps matching for matches handler/, 'Checking DDGTest::Goodie::WrongThree for crashing proper');

eval q{
	use DDGTest::Goodie::WrongFour;
};
like($@, qr/You must be using words matching for remainder handler/, 'Checking DDGTest::Goodie::WrongFour for crashing proper');

done_testing;
