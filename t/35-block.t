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

BEGIN {

	my $re_block = DDG::Block::Regexp->new({
		plugins => [qw(
			DDGTest::Goodie::Regexp
		)],
	});

	isa_ok($re_block,'DDG::Block::Regexp');

	my $hash_block = DDG::Block::Words->new({
		plugins => [qw(
			DDGTest::Goodie::Simple
		)],
	});

	isa_ok($hash_block,'DDG::Block::Words');

	my $any_block = DDG::Block::Any->new({
		plugins => [qw(
			DDGTest::Goodie::Simple
		)],
	});

	isa_ok($any_block,'DDG::Block::Any');

	my %queries = (
		'foo blub blaeh' => {
		},
		'  foo blaeh' => {
		},
	);
	
	for (sort keys %queries) {
		my $query = DDG::Request->new({ query_raw => $_ });
		my $expect = $queries{$_};
		my @hash_result = $hash_block->request($query);
		is_deeply(\@hash_result,$expect->{hash} ? $expect->{hash} : [],'Testing hash block result of query "'.$_.'"');
		my @re_result = $re_block->request($query);
		is_deeply(\@re_result,$expect->{re} ? $expect->{re} : [],'Testing regexp block result of query "'.$_.'"');
		my @any_result = $any_block->request($query);
		is_deeply(\@any_result,$expect->{any} ? $expect->{any} : [],'Testing any block result of query "'.$_.'"');
	}
	
}

done_testing;
