#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Block::Any;
use DDG::Block::Regexp;
use DDG::Block::Words;
use DDG::Request;
use DDG::ZeroClickInfo;

sub zci {
	my ( $answer, $answer_type, $is_cached ) = @_;
	DDG::ZeroClickInfo->new(
		answer => $answer,
		answer_type => $answer_type,
		is_cached => $is_cached ? 1 : 0,
	);
}

BEGIN {

	my $re_block = DDG::Block::Regexp->new({
		plugins => [qw(
			DDGTest::Goodie::ReBlockOne
		)],
	});

	isa_ok($re_block,'DDG::Block::Regexp');

	my $words_block = DDG::Block::Words->new({
		plugins => [qw(
			DDGTest::Goodie::WoBlockOne
			DDGTest::Goodie::WoBlockTwo
			DDGTest::Goodie::WoBlockThree
		)],
	});

	isa_ok($words_block,'DDG::Block::Words');

	my @queries = (
		'aROUNd two' => {
			wo => [zci('two','woblockone')],
			re => [],
		},
		'whatever around two around whatever' => {
			wo => [zci('whatever around around whatever','woblocktwo')],
			re => [],
		},
		'        whatever around three around whatever           ' => {
			wo => [zci('whatever around three around whatever','woblockthree')],
			re => [],
		},
		'whatever ArouND' => {
			wo => [zci('whatever','woblockone')],
			re => [],
		},
		'regexp xxxxx xxxxx' => {
			wo => [],
			re => [zci('xxxxx xxxxx','reblockone')],
		},
		'  regexp		xXXXx aFTEr  ' => {
			wo => [zci('  regexp		xXXXx','woblockone')],
			re => [zci('	xXXXx aFTEr  ','reblockone')],
		},
	);
	
	while (@queries) {
		my $query = shift @queries;
		my $expect = shift @queries;
		my $request = DDG::Request->new({ query_raw => $query });
		my @words_result = $words_block->request($request);
		is_deeply(\@words_result,$expect->{wo} ? $expect->{wo} : [],'Testing words block result of query "'.$query.'"');
		my @re_result = $re_block->request($request);
		is_deeply(\@re_result,$expect->{re} ? $expect->{re} : [],'Testing regexp block result of query "'.$query.'"');
	}
	
}

done_testing;
