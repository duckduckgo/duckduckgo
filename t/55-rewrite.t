#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Rewrite;

eval {
	DDG::Rewrite->new(
		path => '/js/test',
		to => 'http://some.api/$1&cb={{callback}}',
	);
};
like($@,qr/Missing callback attribute for {{callback}}/,'Seeking proper error on missing callback');

delete $ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY} if defined $ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY};

my $missing_rewrite = DDG::Rewrite->new(
	path => '/js/test',
	from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
	to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'buh',
);

isa_ok($missing_rewrite,'DDG::Rewrite');

is_deeply($missing_rewrite->missing_envs,['DDGTEST_DDG_REWRITE_TEST_API_KEY'],'Checking missing ENV');

$ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY} = 1;

my $rewrite = DDG::Rewrite->new(
	path => '/js/test',
	from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
	to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'test',
	wrap_jsonp_callback => 1,
);

isa_ok($rewrite,'DDG::Rewrite');

is($rewrite->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($rewrite->nginx_conf,'location ^~ /js/test {
	echo_before_body \'test(\';
	rewrite ^/js/test([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|) /$1/?a=$2&b=$3&cb=test&ak=1 break;
	proxy_pass http://some.api/;
	echo_after_body \');\';
}
','Checking generated nginx.conf');

done_testing;
