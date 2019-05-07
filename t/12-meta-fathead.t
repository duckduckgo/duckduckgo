#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Fathead::MetaOnly;

my $metaonly = DDGTest::Fathead::MetaOnly->new( block => undef );

isa_ok($metaonly,'DDGTest::Fathead::MetaOnly');

is_deeply(DDGTest::Fathead::MetaOnly->get_attributions,[
	'https://twitter.com/someone', '@someone',
],'Checking resulting get_attributions of DDGTest::Fathead::MetaOnly');

is_deeply(DDGTest::Fathead::MetaOnly->get_category,
	'software',
'Checking resulting get_category of DDGTest::Fathead::MetaOnly');

is_deeply(DDGTest::Fathead::MetaOnly->get_meta_information,{
	name => 'myFathead',
	primary_example_queries => ['primary trigger for myFathead', 'another primary trigger for myFathead'],
	secondary_example_queries => ['secondary trigger for myFathead', 'another secondary trigger for myFathead'],
	icon_url => '/i/mysite.com.ico',
	code_url => 'http://github.com/myFathead',
	source => 'myFathead|Source',
	description => 'describes myFathead',
	status => 'enabled'
},'Checking resulting get_meta_information of DDGTest::Fathead::MetaOnly');

is_deeply(DDGTest::Fathead::MetaOnly->get_topics,[
	'programming', 'sysadmin',
],'Checking resulting get_topics of DDGTest::Fathead::MetaOnly');

eval q{
	use DDGTest::Fathead::WrongMetaOnlyTwoCategories;
};
like($@, qr/Only one category allowed/, 'Checking DDGTest::Fathead::WrongMetaOnlyTwoCategories for crashing proper');

eval q{
	use DDGTest::Fathead::WrongMetaOnlyBadURL;
};
like($@, qr/BROKEN is not a valid URL/, 'Checking DDGTest::Fathead::WrongMetaOnlyBadURL for crashing proper');

done_testing;
