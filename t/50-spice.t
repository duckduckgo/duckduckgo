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

my $re = DDGTest::Spice::Regexp->new( block => undef );

isa_ok($re,'DDGTest::Spice::Regexp');

is_deeply(DDGTest::Spice::Regexp->get_triggers,{
	query_raw => [qr/aregexp (.*)/i, qr/bregexp (.*) (.*)/i, qr/cregexp (.*)/i]
},'Checking resulting get_triggers of DDGTest::Spice::Regexp',);

my $zci_spice = DDG::ZeroClickInfo::Spice->new(
	caller => 'DDGTest::Spice::SomeThing',
	call => ['a##a','b  b','c#??c'],
);

isa_ok($zci_spice,'DDG::ZeroClickInfo::Spice');

#is($zci_spice->caller->path,'/js/spice/some_thing/','Checking for proper path');
#is($zci_spice->caller->callback,'ddgtest_spice_some_thing','Checking for proper callback');
#is($zci_spice->call_path,'/js/spice/some_thing/a%23%23a/b%20%20b/c%23%3F%3Fc','Checking for proper call path');
#is($zci_spice->caller->nginx_conf,<<'__END_OF_CONF__','Checking for proper nginx.conf snippet');

#location ^~ /js/spice/some_thing/ {
#  rewrite ^/js/spice/some_thing/([^/]+)/(?:([^/]+)/(?:([^/]+)|)|) /software/$1/?$2&$3&count=6&callback=nrat break;
#  proxy_pass http://api.alternativeto.net/;
#}

#__END_OF_CONF__

done_testing;
