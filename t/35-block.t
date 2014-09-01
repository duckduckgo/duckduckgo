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

use Scalar::Util qw( refaddr );

sub zci {
	my ( $answer, $answer_type, $caller, $is_cached, %extra_attributes ) = @_;
	DDG::ZeroClickInfo->new(
        caller => $caller,
		answer => $answer,
		answer_type => $answer_type,
		is_cached => $is_cached ? 1 : 0,
		%extra_attributes,
	);
}

BEGIN {

	my $re_plugins = [qw(
		DDGTest::Goodie::ReBlockOne
	)];
	my $before_rp = 0;
	my $after_rp = 0;

	my $re_block = DDG::Block::Regexp->new({
		plugins => $re_plugins,
		before_build => sub {
			my ( $self, $class ) = @_;
			ok($class eq $re_plugins->[$before_rp],'$class should be '.$re_plugins->[$before_rp]);
			$before_rp++;
			ok($class eq $_,'Checking $_ parameter is equal to $_[1]');
		},
		after_build => sub {
			my ( $self, $plugin ) = @_;
			ok(ref $plugin eq $re_plugins->[$after_rp],'$plugin should be ref '.$re_plugins->[$after_rp]);
			$after_rp++;
			ok(refaddr $plugin == refaddr $_,'Checking $_ parameter is equal to $_[1]');
		},
	});

	isa_ok($re_block,'DDG::Block::Regexp');

	my $words_plugins = [qw(
		DDGTest::Goodie::WoBlockBang
		DDGTest::Goodie::WoBlockOne
		DDGTest::Goodie::WoBlockTwo
		DDGTest::Goodie::WoBlockThree
		DDGTest::Goodie::WoBlockArr
		DDGTest::Goodie::CollideOne
		DDGTest::Goodie::CollideTwo
	)];
	my $before_wp = 0;
	my $after_wp = 0;

	eval {
		DDG::Block::Words->new({ plugins => [qw( DDG::QQQQQQQQQQ::QQQQQQQQQQQ )] });
	};
	like($@, qr/Can't load plugin DDG::QQQQQQQQQQ::QQQQQQQQQQQ/, "Checking for failing block cause of missing plugin");

	eval {
		DDG::Block::Words->new({
			plugins => [qw( DDG::QQQQQQQQQQ::QQQQQQQQQQQ )],
			allow_missing_plugins => 1,
		});
	};
	ok(!$@, "Checking allow_missing_plugins with true value");

	my $test_var = 0;
	eval {
		DDG::Block::Words->new({
			plugins => [qw( DDG::QQQQQQQQQQ::QQQQQQQQQQQ )],
			allow_missing_plugins => sub { $test_var = (ref $_[0])." ".$_[1] },
		});
	};
	is($test_var, "DDG::Block::Words DDG::QQQQQQQQQQ::QQQQQQQQQQQ", "Checking allow_missing_plugins with CODEREF");

	my $words_block = DDG::Block::Words->new({
		plugins => $words_plugins,
		return_one => 0,
		before_build => sub {
			my ( $self, $class ) = @_;
			ok($class eq $words_plugins->[$before_wp],'$class should be '.$words_plugins->[$before_wp]);
			$before_wp++;
			ok($class eq $_,'Checking $_ parameter is equal to $_[1]');
		},
		after_build => sub {
			my ( $self, $plugin ) = @_;
			ok(ref $plugin eq $words_plugins->[$after_wp],'$plugin should be ref '.$words_plugins->[$after_wp]);
			$after_wp++;
			ok(refaddr $plugin == refaddr $_,'Checking $_ parameter is equal to $_[1]');
		},
	});

	isa_ok($words_block,'DDG::Block::Words');

	my @queries = (
		'aROUNd two' => {
			wo => [zci('two','woblockone', 'DDGTest::Goodie::WoBlockOne'),zci('aROUNd','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'wikipedia blub' => {
			wo => [],
			re => [],
		},
		'bla !wikipedia blub' => {
			wo => [zci('bla blub','woblockbang', 'DDGTest::Goodie::WoBlockBang')],
			re => [],
		},
		'!h-ow   to   do a   search   engine' => {
			wo => [zci('a   search   engine','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		' how  to   ' => {
			wo => [],
			re => [],
		},
		'  !How to  Do a   search   engine?   ' => {
			wo => [zci('a   search   engine?   ','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'  how-to  do? a   search   engine?   ' => {
			wo => [zci('a   search   engine?   ','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'  !how--TO--do a   search   engine?   ' => {
			wo => [zci('a   search   engine?   ','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'  really bLACk  mAGIc my code!!  ' => {
			wo => [zci('  really my code!!  ','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'  duckduckgo for the win   ' => {
			wo => [zci('  duckduckgo','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'  duckduckgo for-the-win' => {
			wo => [zci('  duckduckgo','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'whatever around two around whatever' => {
			wo => [zci('whatever around around whatever','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')],
			re => [],
		},
		'        whatever around three around whatever           ' => {
			wo => [zci('whatever around three around whatever','woblockthree', 'DDGTest::Goodie::WoBlockThree')],
			re => [],
		},
		'whatever !ArouND' => {
			wo => [zci('whatever','woblockone', 'DDGTest::Goodie::WoBlockOne')],
			re => [],
		},
		'regexp xxxxx xxxxx' => {
			wo => [],
			re => [zci('xxxxx xxxxx','reblockone', 'DDGTest::Goodie::ReBlockOne')],
		},
		'  rEGExp		xXXXx aFTEr  ' => {
			wo => [zci('  rEGExp		xXXXx','woblockone', 'DDGTest::Goodie::WoBlockOne')],
			re => [zci('	xXXXx aFTEr  ','reblockone', 'DDGTest::Goodie::ReBlockOne')],
		},
		'  a    or     b   or        c  ' => {
			wo => [zci('a|or|b|or|c','woblockarr', 'DDGTest::Goodie::WoBlockArr')],
			re => [],
		},
		'collide' => {
			wo => [zci('collide','collideone', 'DDGTest::Goodie::CollideOne'),zci('collide','collidetwo', 'DDGTest::Goodie::CollideTwo')],
			re => [],
		},
	    'or two' => {
			wo => [zci('or|two','woblockarr', 'DDGTest::Goodie::WoBlockArr'), zci('or','woblocktwo', 'DDGTest::Goodie::WoBlockTwo')], 
			re => [],
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


	my $one_words_block = DDG::Block::Words->new({
		plugins => $words_plugins,
		return_one => 1,
	});

	my @one_queries = (
		'aROUNd two' => {
			wo => [zci('two','woblockone', 'DDGTest::Goodie::WoBlockOne')],
			re => [],
		},
		'  a    or     b   or        c  ' => {
			wo => [zci('a|or|b|or|c','woblockarr', 'DDGTest::Goodie::WoBlockArr')],
			re => [],
		},
		'collide' => {
			wo => [zci('collide','collideone', 'DDGTest::Goodie::CollideOne')],
			re => [],
		},
	    'or two' => {
			wo => [zci('or|two','woblockarr', 'DDGTest::Goodie::WoBlockArr')], 
			re => [],
	    },

	);
	
	while (@one_queries) {
		my $query = shift @one_queries;
		my $expect = shift @one_queries;
		my $request = DDG::Request->new({ query_raw => $query });
		my @words_result = $one_words_block->request($request);
		is_deeply(\@words_result,$expect->{wo} ? $expect->{wo} : [],'Testing words block result of query "'.$query.'"');
	}

	# evil test for a plugin that somehow manages to change the query
	# on the processing...
	{
		my $query_change = DDG::Block::Words->new({
			plugins => [qw( DDGTest::Goodie::Changequery )],
			return_one => 1,
		});
		my $request = DDG::Request->new({ query_raw => 'duckduckgo ios' });
		is($request->query_raw,'duckduckgo ios','Query is fine before query_change block');
		my @words_result = $query_change->request($request);
		is($request->query_raw,'duckduckgo ios','Query is still fine after query_change block');
	}
		
}

done_testing;
