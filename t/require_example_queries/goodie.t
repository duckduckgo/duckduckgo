#!/usr/bin/env perl

use strict;
use warnings;
use Test::Most;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use DDG::Test::Goodie;

zci 'answer_type' => 'goodie_example_queries';

$ENV{DDG_REQUIRE_EXAMPLE_QUERIES_TEST} = 1;

dies_ok {
    ddg_goodie_test(
        [qw/ DDGTest::Goodie::RequireExampleQueries /],
        'first trigger a' => test_zci('a'),  
    );
} 'Dies when primary/secondary examples are not tested';

lives_ok {
    ddg_goodie_test(
        [qw/ DDGTest::Goodie::RequireExampleQueries /],
        'first trigger a'  => test_zci('a'),  
        'second trigger b' => test_zci('b'),  
        'second trigger c' => test_zci('c'),  
        'first trigger d'  => test_zci('d'),  
    );
} 'Lives when primary/secondary examples are tested';

done_testing;
