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
$ENV{DDGTEST_BASIC_AUTH_USERNAME} = 'aladdin';
$ENV{DDGTEST_BASIC_AUTH_PASSWORD} = 'opensesame';

my $missing_rewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
	to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'buh',
);

isa_ok($missing_rewrite,'DDG::Rewrite');

is_deeply($missing_rewrite->missing_envs,['DDGTEST_DDG_REWRITE_TEST_API_KEY'],'Checking missing ENV');

$ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY} = 1;

my $rewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
	to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'test',
	proxy_cache_valid => '418 1d',
	wrap_jsonp_callback => 1,
);

isa_ok($rewrite,'DDG::Rewrite');

is($rewrite->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($rewrite->nginx_conf,'location ^~ /js/spice/spice_name/ {
	proxy_set_header Accept-Encoding \'\';
	more_set_headers \'Content-Type: application/javascript; charset=utf-8\';
	echo_before_body \'test(\';
	set $spice_name_upstream http://some.api:80;
	rewrite ^/js/spice/spice_name/([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|) /$1/?a=$2&b=$3&cb=test&ak=1 break;
	proxy_pass $spice_name_upstream;
	proxy_cache_valid 418 1d;
	proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
	echo_after_body \');\';
	proxy_intercept_errors on;
	error_page 301 302 303 403 404 500 502 503 504 =200 /js/failed/test;
	expires 1s;
}
','Checking generated nginx.conf');

my $dollarrewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'http://some.api/{{dollar}}',
);

is($dollarrewrite->nginx_conf,'location ^~ /js/spice/spice_name/ {
	set $spice_name_upstream http://some.api:80;
	rewrite ^/js/spice/spice_name/(.*) /${dollar} break;
	proxy_pass $spice_name_upstream;
	expires 1s;
}
','Checking {{dollar}} replacement');

my $minrewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'http://some.api/$1',
);

isa_ok($minrewrite,'DDG::Rewrite');

is($minrewrite->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($minrewrite->nginx_conf,'location ^~ /js/spice/spice_name/ {
	set $spice_name_upstream http://some.api:80;
	rewrite ^/js/spice/spice_name/(.*) /$1 break;
	proxy_pass $spice_name_upstream;
	expires 1s;
}
','Checking generated nginx.conf');

my $minrewrite_https = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'https://some.api/$1',
);

isa_ok($minrewrite_https,'DDG::Rewrite');

is($minrewrite_https->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($minrewrite_https->nginx_conf,'location ^~ /js/spice/spice_name/ {
	set $spice_name_upstream https://some.api:443;
	rewrite ^/js/spice/spice_name/(.*) /$1 break;
	proxy_pass $spice_name_upstream;
	proxy_ssl_server_name on;
	expires 1s;
}
','Checking generated nginx.conf');

my $minrewrite_with_port = DDG::Rewrite->new(
	path => '/js/spice/spice_test2/',
	to => 'http://some.api:3000/$1',
);

isa_ok($minrewrite_with_port,'DDG::Rewrite');

is($minrewrite_with_port->missing_envs ? 1 : 0,0,'Checking now not missing ENV');
is($minrewrite_with_port->nginx_conf,'location ^~ /js/spice/spice_test2/ {
	set $spice_test2_upstream http://some.api:3000;
	rewrite ^/js/spice/spice_test2/(.*) /$1 break;
	proxy_pass $spice_test2_upstream;
	expires 1s;
}
','Checking generated nginx.conf');

my $localhostrewrite = DDG::Rewrite->new(
       path => '/js/spice/spice_test/',
       to => 'https://127.0.0.1',
);
isa_ok($localhostrewrite,'DDG::Rewrite');
like($localhostrewrite->nginx_conf,qr/X-Forwarded-For/,'Checking localhost rewrite');

my $ddgrewrite = DDG::Rewrite->new(
       path => '/js/spice/spice_test/',
       to => 'https://duckduckgo.com',
);
isa_ok($ddgrewrite,'DDG::Rewrite');
like($ddgrewrite->nginx_conf,qr/X-Forwarded-For/,'Checking DuckDuckGo rewrite');

my $headers_rewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'https://some.api/$1',
	headers => 'Accept "application/vnd.citationstyles.csl+json"',
	basic_auth => {
		username => $ENV{DDGTEST_BASIC_AUTH_USERNAME},
		password => $ENV{DDGTEST_BASIC_AUTH_PASSWORD},
	}
);

my $headers_nginx_conf = 'location ^~ /js/spice/spice_name/ {
	proxy_set_header Authorization "Basic YWxhZGRpbjpvcGVuc2VzYW1l";
	proxy_set_header Accept "application/vnd.citationstyles.csl+json";
	set $spice_name_upstream https://some.api:443;
	rewrite ^/js/spice/spice_name/(.*) /$1 break;
	proxy_pass $spice_name_upstream;
	proxy_ssl_server_name on;
	expires 1s;
}
';

is($headers_rewrite->nginx_conf, $headers_nginx_conf,'Checking generated nginx.conf with custom headers');

$headers_rewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'https://some.api/$1',
	headers => [ q{Accept "application/vnd.citationstyles.csl+json"} ],
	basic_auth => $ENV{DDGTEST_BASIC_AUTH_USERNAME} . ':' . $ENV{DDGTEST_BASIC_AUTH_PASSWORD},
);

is($headers_rewrite->nginx_conf, $headers_nginx_conf, 'Checking generated nginx.conf with custom headers (array)');

$headers_rewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'https://some.api/$1',
	headers => { Accept => 'application/vnd.citationstyles.csl+json' },
	basic_auth => {
		username => $ENV{DDGTEST_BASIC_AUTH_USERNAME},
		password => $ENV{DDGTEST_BASIC_AUTH_PASSWORD},
	}
);

is($headers_rewrite->nginx_conf, $headers_nginx_conf, 'Checking generated nginx.conf with custom headers (hash)');

$headers_rewrite = DDG::Rewrite->new(
	path => '/js/spice/spice_name/',
	to => 'https://some.api/$1',
	headers => {
	       Accept => 'application/vnd.citationstyles.csl+json',
	       Range  => '1024-2047',
	}
);

is($headers_rewrite->nginx_conf, 'location ^~ /js/spice/spice_name/ {
	proxy_set_header Accept "application/vnd.citationstyles.csl+json";
	proxy_set_header Range "1024-2047";
	set $spice_name_upstream https://some.api:443;
	rewrite ^/js/spice/spice_name/(.*) /$1 break;
	proxy_pass $spice_name_upstream;
	proxy_ssl_server_name on;
	expires 1s;
}
', 'Checking generated nginx.conf with custom headers (hash multi)');

my $upstream_rewrite = DDG::Rewrite->new(
        path => '/js/spice/spice_name/',
        from => '([^/]+)/?(?:([^/]+)/?(?:([^/]+)|)|)',
        to => 'http://some.api/$1/?a=$2&b=$3&cb={{callback}}&ak={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
	callback => 'test',
);

like($upstream_rewrite->nginx_conf, qr/set \$spice_name_upstream http:\/\/some\.api:80;/,'Checking upstream rewrite');

done_testing;
