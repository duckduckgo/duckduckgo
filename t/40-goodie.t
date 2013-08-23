#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Goodie::Words;
use DDGTest::Goodie::Regexp;
use DDGTest::Goodie::TriggerOverlap;

my $goodie = DDGTest::Goodie::Words->new( block => undef );

isa_ok($goodie,'DDGTest::Goodie::Words');

is_deeply(DDGTest::Goodie::Words->get_triggers,{
	startend => [ "foo", "foofoo", "afoo", "afoofoo" ],
	start => [ "bar", "baz", "buu", "abar", "abaz" ],
},'Checking resulting get_triggers of DDGTest::Goodie::Words');

my $re = DDGTest::Goodie::Regexp->new( block => undef );

isa_ok($re,'DDGTest::Goodie::Regexp');

is_deeply(DDGTest::Goodie::Regexp->get_triggers,{
	query_raw => [qr/aregexp (.*)/i, qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i]
},'Checking resulting get_triggers of DDGTest::Goodie::Regexp',);

eval q{
	use DDGTest::Goodie::WrongOne;
};
like($@, qr/Please define triggers before you define a handler/, 'Checking DDGTest::Goodie::WrongOne for crashing proper');

eval q{
	use DDGTest::Goodie::WrongTwo;
};
like($@, qr/you cant add trigger types of the other block-type/, 'Checking DDGTest::Goodie::WrongTwo for crashing proper');

eval q{
	use DDGTest::Goodie::WrongThree;
};
like($@, qr/You must be using regexps matching for matches handler/, 'Checking DDGTest::Goodie::WrongThree for crashing proper');

eval q{
	use DDGTest::Goodie::WrongFour;
};
like($@, qr/You must be using words matching for remainder handler/, 'Checking DDGTest::Goodie::WrongFour for crashing proper');

# Check that overlapping triggers are created
$goodie = DDGTest::Goodie::TriggerOverlap->new( block => undef );

isa_ok($goodie,'DDGTest::Goodie::TriggerOverlap');

is_deeply(DDGTest::Goodie::TriggerOverlap->get_triggers,{
	start => [ "myTrigger", "myTrigger start" ],
	end => [ "myTrigger", "end myTrigger" ],
	any => [ "myTrigger" ],
	# startend => [ "myTrigger", "myTrigger startend" ],
},'Checking resulting get_triggers of DDGTest::Goodie::TriggerOverlap');

done_testing;