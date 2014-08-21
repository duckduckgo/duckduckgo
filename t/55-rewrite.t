#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Rewrite;

eval {
	DDG::Rewrite->new(
		path => '/js/test/',
		to => 'http://some.api/$1&cb={{callback}}',
	);
};
like($@,qr/Missing callback attribute for {{callback}}/,'Seeking proper error on missing callback');

delete $ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY} if defined $ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY};

my $missing_rewrite = DDG::Rewrite->new(
	path => '/js/test/',
	from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
	to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'buh',
);

isa_ok($missing_rewrite,'DDG::Rewrite');

is_deeply($missing_rewrite->missing_envs,['DDGTEST_DDG_REWRITE_TEST_API_KEY'],'Checking missing ENV');

$ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY} = 1;

my $rewrite = DDG::Rewrite->new(
	path => '/js/test/',
	from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
	to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'test',
	proxy_cache_valid => '418 1d',
	wrap_jsonp_callback => 1,
);

isa_ok($rewrite,'DDG::Rewrite');

is($rewrite->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($rewrite->nginx_conf,'location ^~ /js/test/ {
	proxy_set_header Accept-Encoding \'\';
	more_set_headers \'Content-Type: application/javascript; charset=utf-8\';
	include /usr/local/nginx/conf/nginx_inc_proxy_headers.conf;
	echo_before_body \'test(\';
	rewrite ^/js/test/([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|) /$1/?a=$2&b=$3&cb=test&ak=1 break;
	proxy_pass http://some.api:80/;
	proxy_cache_valid 418 1d;
	proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
	echo_after_body \');\';
	proxy_intercept_errors on;
	error_page 301 302 303 403 404 500 502 503 504 =200 /js/failed/test;
}
','Checking generated nginx.conf');

my $dollarrewrite = DDG::Rewrite->new(
	path => '/js/test/',
	to => 'http://some.api/{{dollar}}',
);

is($dollarrewrite->nginx_conf,'location ^~ /js/test/ {
	rewrite ^/js/test/(.*) /${dollar} break;
	proxy_pass http://some.api:80/;
}
','Checking {{dollar}} replacement');

my $minrewrite = DDG::Rewrite->new(
	path => '/js/test/',
	to => 'http://some.api/$1',
);

isa_ok($minrewrite,'DDG::Rewrite');

is($minrewrite->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($minrewrite->nginx_conf,'location ^~ /js/test/ {
	rewrite ^/js/test/(.*) /$1 break;
	proxy_pass http://some.api:80/;
}
','Checking generated nginx.conf');

my $minrewrite_https = DDG::Rewrite->new(
	path => '/js/test/',
	to => 'https://some.api/$1',
);

isa_ok($minrewrite_https,'DDG::Rewrite');

is($minrewrite_https->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($minrewrite_https->nginx_conf,'location ^~ /js/test/ {
	rewrite ^/js/test/(.*) /$1 break;
	proxy_pass https://some.api:443/;
}
','Checking generated nginx.conf');

my $minrewrite_with_port = DDG::Rewrite->new(
	path => '/js/test2/',
	to => 'http://some.api:3000/$1',
);

isa_ok($minrewrite_with_port,'DDG::Rewrite');

is($minrewrite_with_port->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($minrewrite_with_port->nginx_conf,'location ^~ /js/test2/ {
	rewrite ^/js/test2/(.*) /$1 break;
	proxy_pass http://some.api:3000/;
}
','Checking generated nginx.conf');

my $localhostrewrite = DDG::Rewrite->new(
       path => '/js/test/',
       to => 'https://127.0.0.1',
);
isa_ok($localhostrewrite,'DDG::Rewrite');
like($localhostrewrite->nginx_conf,qr/X-Forwarded-For/,'Checking localhost rewrite');

my $ddgrewrite = DDG::Rewrite->new(
       path => '/js/test/',
       to => 'https://duckduckgo.com',
);
isa_ok($ddgrewrite,'DDG::Rewrite');
like($ddgrewrite->nginx_conf,qr/X-Forwarded-For/,'Checking DuckDuckGo rewrite');

done_testing;
