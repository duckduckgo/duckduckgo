#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Spice::Words;
use DDGTest::Spice::Regexp;

use DDG::ZeroClickInfo::Spice;

my $spice = DDGTest::Spice::Words->new( block => undef );

isa_ok($spice,'DDGTest::Spice::Words');

is_deeply(DDGTest::Spice::Words->get_triggers,{
	startend => [ "foo", "foofoo", "afoo", "afoofoo" ],
	start => [ "bar", "baz", "buu", "abar", "abaz" ],
},'Checking resulting get_triggers of DDGTest::Spice::Words');

is_deeply(DDGTest::Spice::Words->get_attributions,[
	'https://facebook.com/duckduckgo', 'DuckDuckGo',
	'https://twitter.com/duckduckgo', '@duckduckgo',
	'mailto:hulk@avengers.com', 'Hulk of the Avengers',
],'Checking resulting get_attributions of DDGTest::Spice::Words');

is(DDGTest::Spice::Words->get_nginx_conf,"bla","Checking nginx_conf override");
is(DDGTest::Spice::Words->path,'/js/spice/words/','Checking for proper path');
is(DDGTest::Spice::Words->callback,'ddgtest_spice_words','Checking for proper callback');

my $re = DDGTest::Spice::Regexp->new( block => undef );

isa_ok($re,'DDGTest::Spice::Regexp');

is_deeply(DDGTest::Spice::Regexp->get_triggers,{
	query_raw => [qr/aregexp (.*)/i, qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i]
},'Checking resulting get_triggers of DDGTest::Spice::Regexp',);

is(DDGTest::Spice::Regexp->get_nginx_conf,'location ^~ /js/spice/regexp/ {
	rewrite ^/js/spice/regexp/(.*) / break;
	proxy_pass http://some.api/;
}
',"Checking standard nginx_conf");

my $zci_spice = DDG::ZeroClickInfo::Spice->new(
	caller => 'DDGTest::Spice::SomeThing',
	call => '/js/spice/some_thing/a%23%23a/b%20%20b/c%23%3F%3Fc',
);

isa_ok($zci_spice,'DDG::ZeroClickInfo::Spice');
is($zci_spice->call,'/js/spice/some_thing/a%23%23a/b%20%20b/c%23%3F%3Fc','Checking for proper call path');

done_testing;
