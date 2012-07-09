#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Goodie;
use DDG::Test::Location;
use DDG::Request;

zci answer_type => 'location';

my @location_tests = (
	de => 'Germany Nordrhein-Westfalen Mönchengladbach',
	my => 'Malaysia Kuala Lumpur Kuala Lumpur',
	in => 'India Delhi New Delhi',
);

while (@location_tests) {
	my $location_key = shift @location_tests;
	my $expected_reply = shift @location_tests;
	my $loc = test_location($location_key);
	my $req = DDG::Request->new( query_raw => "my location", location => $loc );
	ddg_goodie_test(
		[qw(
			DDGTest::Goodie::Location
		)],
		$req, test_zci($expected_reply),
	);
}

done_testing;
