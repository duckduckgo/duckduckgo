#!/usr/bin/env perl

use strict;
use warnings;
use Test::Most;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDG::Test::Goodie;
use DDGTest::Goodie::Words;
use DDGTest::Goodie::WordsWithEmptyShare;
use DDGTest::Goodie::WordsWithShare;

zci answer_type => 'wordswithshare';

subtest 'with_style_css' => sub {
    ddg_goodie_test([qw(
              DDGTest::Goodie::WordsWithShare
              )
        ],
        'foo doo' => test_zci('doo', html => qr/valid boring css/),
    );

    throws_ok {
        ddg_goodie_test([qw(
                  DDGTest::Goodie::WordsWithEmptyShare
                  )
            ],
            'foo doo' => test_zci('doo', html => qr/valid boring css/),
        );
    }
    qr/Undefined subroutine.*with_style_css/, 'with_style_css only installed when style.css is in the share directory';
};

done_testing;
