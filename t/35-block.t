#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use DDG::Block::Regexp;
use DDG::Query;

BEGIN {

	my $re_block = DDG::Block::Regexp->new({
		plugins => [qw(
			Sample::Regexp
			Sample::Regexp::Matches
		)],
	});

	isa_ok($re_block,'DDG::Block::Regexp');

	for (
		'bla blub blaeh',
		'blub xxxx',
		'bluub xyz',
		'  test test 1 2 3',
		'reverse 14',
		'  reverse 14'
	) {
		my $query = DDG::Query->new({ query => $_ });
		my @result = $re_block->query($query);
	}
	
}

done_testing;
