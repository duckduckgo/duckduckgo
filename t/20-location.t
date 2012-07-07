#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8::all;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Goodie;
use DDG::Location;
use DDG::Request;

my $loc = DDG::Location->new(
	country_code => 'US',
	country_code3 => 'USA',
	country_name => 'United States',
	region => 'PA',
	region_name => 'Pennsylvania',
	city => 'Phoenixville',
	postal_code => '19460',
	latitude => '40.1246',
	longitude => '-75.5385',
	time_zone => 'America/New_York',
	area_code => '610',
	continent_code => 'NA',
	metro_code => '504',
);

my $req = DDG::Request->new( query_raw => "my location", location => $loc );

zci answer_type => 'location';

ddg_goodie_test(
	[qw(
		DDGTest::Goodie::Location
	)],
	$req, test_zci('United States Pennsylvania Phoenixville'),
);

done_testing;
