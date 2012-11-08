#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Block::Any;

use DDGTest::Fathead::MetaOnly;
use DDGTest::Longtail::MetaOnly;

my $fhmetaonly = DDGTest::Fathead::MetaOnly->new( block => undef );

isa_ok($fhmetaonly,'DDGTest::Fathead::MetaOnly');

my $ltmetaonly = DDGTest::Longtail::MetaOnly->new( block => undef );

isa_ok($ltmetaonly,'DDGTest::Longtail::MetaOnly');

my @plugins = qw(
	DDGTest::Fathead::MetaOnly
	DDGTest::Longtail::MetaOnly
);

my $anyblock = DDG::Block::Any->new(
	plugins => [@plugins],
);

my $cnt = 1;
for (@{$anyblock->only_plugin_objs}) {
	is(ref $_,shift @plugins,$cnt.'. plugin ok');
	$cnt++;
}

done_testing;
