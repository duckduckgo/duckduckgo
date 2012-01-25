#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use DDG::Block::Regexp;
use DDG::Block::Hash;
use DDG::Query;

BEGIN {

	my $re_block = DDG::Block::Regexp->new({
		plugins => [qw(
			Sample::Regexp
			Sample::Regexp::Matches
		)],
	});

	isa_ok($re_block,'DDG::Block::Regexp');

	my $are_block = DDG::Block::Regexp->new({
		plugins => [qw(
			Sample::Regexp
			Sample::Regexp::Matches
		)],
		return_one => 0,
	});

	isa_ok($are_block,'DDG::Block::Regexp');

	my $hash_block = DDG::Block::Hash->new({
		plugins => [qw(
			Sample::Hash
		)],
	});

	isa_ok($hash_block,'DDG::Block::Hash');

	my %queries = (
		'bla blub blaeh' => {
			hash => ['DDG::Plugin::Sample::Hash'],
			re => ['DDG::Plugin::Sample::Regexp'],
			are => ['DDG::Plugin::Sample::Regexp'],
		},
		'    bla blaeh' => {
			hash => ['DDG::Plugin::Sample::Hash'],
		},
		'  reverse duckduckgo' => {
			re => ['ogkcudkcud'],
			are => ['ogkcudkcud'],
		},
	);
	
	for (sort keys %queries) {
		my $query = DDG::Query->new({ query => $_ });
		my $expect = $queries{$_};
		my @hash_result = $hash_block->query($query);
		is_deeply(\@hash_result,$expect->{hash} ? $expect->{hash} : [],'Testing hash block result of query "'.$_.'"');
		my @re_result = $re_block->query($query);
		is_deeply(\@re_result,$expect->{re} ? $expect->{re} : [],'Testing regexp block result of query "'.$_.'"');
		my @are_result = $are_block->query($query);
		is_deeply(\@are_result,$expect->{are} ? $expect->{are} : [],'Testing all regexp block result of query "'.$_.'"');
	}
	
}

done_testing;
