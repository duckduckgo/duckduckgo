#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Request;

use DDG::Test::Spice;

use DDGTest::Spice::Words;
use DDGTest::Spice::Regexp;
use DDGTest::Spice::Data;
use DDGTest::Spice::Cached;
use DDGTest::Spice::ChangeCached;
use DDGTest::Spice::EndpointOnly;

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
	'https://metacpan.org/author/GETTY', 'GETTY',
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
	proxy_pass http://some.api:80/;
	proxy_intercept_errors on;
	error_page 301 302 303 403 404 500 502 503 504 =200 /js/failed/ddgtest_spice_regexp;
	expires 1s;
}
',"Checking standard nginx_conf");

my $endpoint_only = DDGTest::Spice::EndpointOnly->new( block => undef );

isa_ok($endpoint_only,'DDGTest::Spice::EndpointOnly');

is(DDGTest::Spice::EndpointOnly->get_nginx_conf,'location ^~ /js/spice/endpoint_only/ {
	include /usr/local/nginx/conf/nginx_inc_proxy_headers.conf;
	rewrite ^/js/spice/endpoint_only/(.*) /?q=$1&format=json&pretty=1 break;
	proxy_pass https://api.duckduckgo.com:443/;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_intercept_errors on;
	error_page 403 404 500 502 503 504 =200 /js/failed/ddgtest_spice_endpoint_only;
}
',"Checking standard nginx_conf");

my $zci_spice = DDG::ZeroClickInfo::Spice->new(
	caller => 'DDGTest::Spice::SomeThing',
	call => '/js/spice/some_thing/a%23%23a/b%20%20b/c%23%3F%3Fc',
);

isa_ok($zci_spice,'DDG::ZeroClickInfo::Spice');
is($zci_spice->call,'/js/spice/some_thing/a%23%23a/b%20%20b/c%23%3F%3Fc','Checking for proper call path');

ddg_spice_test(
	# DDGTest::Spice::Flashtest
	[qw(
		DDGTest::Spice::Data
		DDGTest::Spice::Regexp
		DDGTest::Spice::Cached
		DDGTest::Spice::ChangeCached
	)],
	'data test' => test_spice( 
		'/js/spice/data/test',
		call_data => { otherkey => 'value', key => 'finalvalue' },
		call_type => 'include',
		caller => 'DDGTest::Spice::Data'
	),
	'bregexp test a' => test_spice( 
		'/js/spice/regexp/test.a/DDG%3A%3ARequest',
		call_type => 'include',
		caller => 'DDGTest::Spice::Regexp'
	),
	'testing cached' => test_spice( 
		'/js/spice/cached/testing',
		call_type => 'include',
		caller => 'DDGTest::Spice::Cached',
		is_cached => 1
	),
	'test changed caching' => test_spice( 
		'/js/spice/change_cached/test',
		call_type => 'include',
		caller => 'DDGTest::Spice::ChangeCached',
		is_cached => 1
	),
	'not caching changed caching' => test_spice( 
		'/js/spice/change_cached/not%20caching',
		call_type => 'include',
		caller => 'DDGTest::Spice::ChangeCached',
		is_cached => 0
	),
	# 'flash version' => test_spice( 
	# 	'/js/spice/flashtest',
	# 	call_type => 'self',
	# 	caller => 'DDGTest::Spice::Flashtest'
	# ),
);

done_testing;
