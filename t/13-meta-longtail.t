#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Longtail::MetaOnly;

my $metaonly = DDGTest::Longtail::MetaOnly->new( block => undef );

isa_ok($metaonly,'DDGTest::Longtail::MetaOnly');

is_deeply(DDGTest::Longtail::MetaOnly->get_attributions,[
	'https://twitter.com/someone', '@someone',
],'Checking resulting get_attributions of DDGTest::Longtail::MetaOnly');

is_deeply(DDGTest::Longtail::MetaOnly->get_category,
	'software',
'Checking resulting get_category of DDGTest::Longtail::MetaOnly');

is_deeply(DDGTest::Longtail::MetaOnly->get_meta_information,{
	name => 'myLongtail',
	primary_example_queries => ['primary trigger for myLongtail', 'another primary trigger for myLongtail'],
	secondary_example_queries => ['secondary trigger for myLongtail', 'another secondary trigger for myLongtail'],
	icon_url => '/i/mysite.com.ico',
	code_url => 'http://github.com/myLongtail',
	source => 'myLongtail|Source',
	description => 'describes myLongtail',
	status => 'enabled'
},'Checking resulting get_meta_information of DDGTest::Longtail::MetaOnly');

is_deeply(DDGTest::Longtail::MetaOnly->get_topics,[
	'programming', 'sysadmin',
],'Checking resulting get_topics of DDGTest::Longtail::MetaOnly');

eval q{
	use DDGTest::Longtail::WrongMetaOnlyTwoCategories;
};
like($@, qr/Only one category allowed/, 'Checking DDGTest::Longtail::WrongMetaOnlyTwoCategories for crashing proper');

eval q{
	use DDGTest::Longtail::WrongMetaOnlyBadURL;
};
like($@, qr/BROKEN is not a valid URL/, 'Checking DDGTest::Longtail::WrongMetaOnlyBadURL for crashing proper');

done_testing;
