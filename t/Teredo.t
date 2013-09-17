#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use DDG::Test::Goodie;

zci answer_type => 'teredo';
zci is_cached => 1;

ddg_goodie_test(
    [
        'DDG::Goodie::Teredo'
    ],

    # Sample queries
    'teredo 2001:0000:4136:e378:8000:63bf:3fff:fdd2' =>
        test_zci("Teredo Server IPv4: 65.54.227.120\nNAT Public IPv4: 192.0.2.45\nClient Port: 40000"),
   
    'teredo 2001:0000:4136:E378:8000:EC77:7C94:FFFE' =>
        test_zci("Teredo Server IPv4: 65.54.227.120\nNAT Public IPv4: 131.107.0.1\nClient Port: 5000"),

    'teredo 2001::CE49:7601:E866:EFFF:62C3:FFFE' =>
        test_zci("Teredo Server IPv4: 206.73.118.1\nNAT Public IPv4: 157.60.0.1\nClient Port: 4096"),
);


done_testing;
