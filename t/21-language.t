#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Goodie;
use DDG::Test::Language;
use DDG::Request;

zci answer_type => 'language';

my @language_tests = (
	de => 'German of Germany de_DE',
	my => 'Malay in Malaysia ms_MY',
);

while (@language_tests) {
	my $language_key = shift @language_tests;
	my $expected_reply = shift @language_tests;
	my $lang = test_language($language_key);
	my $req = DDG::Request->new( query_raw => "my language", language => $lang );
	ddg_goodie_test(
		[qw(
			DDGTest::Goodie::Language
		)],
		$req, test_zci($expected_reply),
	);
}

done_testing;
