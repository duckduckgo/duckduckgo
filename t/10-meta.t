#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Goodie;
use DDGTest::Goodie::MetaOnly;

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

my $metaonly = DDGTest::Goodie::MetaOnly->new( block => undef );

isa_ok($metaonly,'DDGTest::Goodie::MetaOnly');

is_deeply(DDGTest::Goodie::MetaOnly->get_attributions,[
	'https://twitter.com/someone', '@someone',
],'Checking resulting get_attributions of DDGTest::Goodie::MetaOnly');

is_deeply(DDGTest::Goodie::MetaOnly->get_category,
	'software',
'Checking resulting get_category of DDGTest::Goodie::MetaOnly');

is_deeply(DDGTest::Goodie::MetaOnly->get_meta_information,{
	name => 'myGoodie',
	primary_example_queries => ['primary trigger for myGoodie', 'another primary trigger for myGoodie'],
	secondary_example_queries => ['secondary trigger for myGoodie', 'another secondary trigger for myGoodie'],
	icon_url => 'http://mysite.com/images/icon',
	code_url => 'http://github.com/myGoodie',
},'Checking resulting get_meta_information of DDGTest::Goodie::MetaOnly');

is_deeply(DDGTest::Goodie::MetaOnly->get_topics,[
	'programming', 'sysadmin',
],'Checking resulting get_topics of DDGTest::Goodie::MetaOnly');

eval q{
	use DDGTest::Goodie::WrongMetaOnlyTwoCategories;
};
like($@, qr/Only one category allowed/, 'Checking DDGTest::Goodie::WrongMetaOnlyTwoCategories for crashing proper');

eval q{
	use DDGTest::Goodie::WrongMetaOnlyBadURL;
};
like($@, qr/BROKEN is not a valid URL/, 'Checking DDGTest::Goodie::WrongMetaOnlyBadURL for crashing proper');

done_testing;
