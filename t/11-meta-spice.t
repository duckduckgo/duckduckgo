#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Spice;
use DDGTest::Spice::MetaOnly;

my $metaonly = DDGTest::Spice::MetaOnly->new( block => undef );

isa_ok($metaonly,'DDGTest::Spice::MetaOnly');

is_deeply(DDGTest::Spice::MetaOnly->get_attributions,[
	'https://twitter.com/someone', '@someone',
],'Checking resulting get_attributions of DDGTest::Spice::MetaOnly');

is_deeply(DDGTest::Spice::MetaOnly->get_category,
	'software',
'Checking resulting get_category of DDGTest::Spice::MetaOnly');

is_deeply(DDGTest::Spice::MetaOnly->get_meta_information,{
	name => 'mySpice',
	primary_example_queries => ['primary trigger for mySpice', 'another primary trigger for mySpice'],
	secondary_example_queries => ['secondary trigger for mySpice', 'another secondary trigger for mySpice'],
	icon_url => '/i/mysite.com.ico',
	code_url => 'http://github.com/mySpice',
	source => 'mySpice|Source',
	description => 'describes mySpice',
	status => 'enabled'
},'Checking resulting get_meta_information of DDGTest::Spice::MetaOnly');

is_deeply(DDGTest::Spice::MetaOnly->get_topics,[
	'programming', 'sysadmin',
],'Checking resulting get_topics of DDGTest::Spice::MetaOnly');

eval q{
	use DDGTest::Spice::WrongMetaOnlyTwoCategories;
};
like($@, qr/Only one category allowed/, 'Checking DDGTest::Spice::WrongMetaOnlyTwoCategories for crashing proper');

eval q{
	use DDGTest::Spice::WrongMetaOnlyBadURL;
};
like($@, qr/BROKEN is not a valid URL/, 'Checking DDGTest::Spice::WrongMetaOnlyBadURL for crashing proper');

done_testing;
