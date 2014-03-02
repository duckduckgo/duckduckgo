#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Fatal qw/dies_ok lives_ok/;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use DDG::Test::Spice;

#zci 'answer_type' => 'spice_example_queries';

$ENV{DDG_REQUIRE_EXAMPLE_QUERIES_TEST} = 1;

dies_ok {
    ddg_spice_test(
        [qw/ DDGTest::Spice::RequireExampleQueries /],
        'boop' => test_spice('boop'),  
    );
} 'Dies when primary/secondary examples are not tested';

my $caller = 'DDGTest::Spice::RequireExampleQueries';
my $prefix = '/js/spice/require_example_queries/';

lives_ok {
    ddg_spice_test(
        [qw/ DDGTest::Spice::RequireExampleQueries /],
        'first trigger a'  => test_spice($prefix . 'a', caller => $caller),  
        'second trigger b' => test_spice($prefix . 'b', caller => $caller),  
        'second trigger c' => test_spice($prefix . 'c', caller => $caller),  
        'first trigger d'  => test_spice($prefix . 'd', caller => $caller),  
    );
} 'Lives when primary/secondary examples are tested';

done_testing;
