#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Spice::Words;
use DDGTest::Spice::Regexp;

my $spice = DDGTest::Spice::Words->new( block => undef );

isa_ok($spice,'DDGTest::Spice::Words');

is_deeply(DDGTest::Spice::Words->get_triggers,{
	startend => [ "foo", "foofoo", "afoo", "afoofoo" ],
	start => [ "bar", "baz", "buu", "abar", "abaz" ],
},'Checking resulting get_triggers of DDGTest::Spice::Words');

my $re = DDGTest::Spice::Regexp->new( block => undef );

isa_ok($re,'DDGTest::Spice::Regexp');

is_deeply(DDGTest::Spice::Regexp->get_triggers,{
	query_raw => [qr/aregexp (.*)/i, qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i]
},'Checking resulting get_triggers of DDGTest::Spice::Regexp',);

done_testing;
