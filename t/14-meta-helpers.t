#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTest::Goodie::MetaOnly;

subtest 'html_enc' => sub {
    subtest 'scalar output' => sub {
        my $res = DDGTest::Goodie::MetaOnly::html_enc('<');
        is($res, '&lt;', 'single input');

        $res = DDGTest::Goodie::MetaOnly::html_enc('>', '<');
        is($res, '&gt;&lt;', 'multiple input gets concatenated elements');
    };

    subtest 'array output' => sub {
        my ($first, $second) = DDGTest::Goodie::MetaOnly::html_enc('<');
        is($first,  '&lt;', 'single input - first element');
        is($second, undef,  'single input - second element');

        ($first, $second) = DDGTest::Goodie::MetaOnly::html_enc('>', '<');
        is($first,  '&gt;', 'multiple input - first element');
        is($second, '&lt;', 'multiple input - second element');

        my @results = DDGTest::Goodie::MetaOnly::html_enc('>', '<');
        is_deeply(\@results, ['&gt;', '&lt;'], 'named array');
    };
};

subtest 'uri_esc' => sub {
    subtest 'scalar output' => sub {
        my $res = DDGTest::Goodie::MetaOnly::uri_esc('<');
        is($res, '%3C', 'single input');

        $res = DDGTest::Goodie::MetaOnly::uri_esc('>', '<');
        is($res, '%3E%3C', 'multiple input gets concatenated elements');
    };

    subtest 'array output' => sub {
        my ($first, $second) = DDGTest::Goodie::MetaOnly::uri_esc('<');
        is($first,  '%3C', 'single input - first element');
        is($second, undef, 'single input - second element');

        ($first, $second) = DDGTest::Goodie::MetaOnly::uri_esc('>', '<');
        is($first,  '%3E', 'multiple input - first element');
        is($second, '%3C', 'multiple input - second element');

        my @results = DDGTest::Goodie::MetaOnly::uri_esc('>', '<');
        is_deeply(\@results, ['%3E', '%3C'], 'named array');
    };
};

subtest 'rand_int' => sub {
	my $res = DDGTest::Goodie::MetaOnly::rand_int();
	ok(($res==0||$res==1), 'no input');

	$res = DDGTest::Goodie::MetaOnly::rand_int(10);
	ok(($res>=0||$res<=10), 'between 0-10');
	ok($res==int($res),   'is integer');

	for (my $i=10; $i<500; $i+=25) {
		$res = DDGTest::Goodie::MetaOnly::rand_int($i);
		ok(($res>=0||$res<=$i), "between 0-$i");
	}
};



done_testing;
