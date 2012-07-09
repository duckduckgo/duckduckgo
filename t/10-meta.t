#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Goodie;

ddg_goodie_test(
	[qw(
		DDGTest::Goodie::Location
		DDGTest::Goodie::Language
		DDGTest::Goodie::Request
	)],
	"my location", test_zci("United States Pennsylvania Phoenixville", answer_type => 'location'),
	"   my request   ", test_zci("   my request   ", answer_type => 'request'),
	"  my language", test_zci("English of United States en_US", answer_type => 'language'),
);

done_testing;
