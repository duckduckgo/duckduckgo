#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use List::Util qw( pairs );

sub parse_test {
    my ($to_parse, $expected, %options) = @_;
    my $parsed = ListTester::parse_list($to_parse, %options);
    cmp_deeply($parsed, $expected, "parse $to_parse");
}

sub parse_test_no {
    my ($to_parse, %options) = @_;
    my $parsed = ListTester::parse_list($to_parse, %options);
    is($parsed, undef, "parse @{[$to_parse // 'undef']}");
}

sub format_test {
    my ($to_format, $expected, %options) = @_;
    my $formatted = ListTester::format_list($to_format, %options);
    cmp_deeply($formatted, $expected, "format @$to_format");
}

subtest initialization => sub {
    { package ListTester; use Moo; with 'DDG::GoodieRole::Parse::List'; 1; }

    new_ok('ListTester', [], 'Applied to a class');
};

subtest parse_list => sub {
    subtest 'varying brackets' => sub {
        my %brackets = (
            '[' => ']',
            '{' => '}',
            '(' => ')',
            ''  => '',
        );
        while (my ($open, $close) = each %brackets) {
            my $test_list = "${open}1, 2, 3$close";
            my $expected  = [1, 2, 3];
            subtest "brackets: $open$close" => sub {
                parse_test($test_list, $expected);
            };
        }
    };

    subtest 'number of items' => sub {
        my %tcs = (
            0 => '[]',
            1 => '[1]',
            2 => '[1, 2]',
            3 => '[1, 2, [3, 4]]',
            4 => '[1, 2, 3, 4]',
        );
        while (my ($amount, $tstring) = each %tcs) {
            subtest "$amount items" => sub {
                parse_test($tstring, arraylength($amount));
            };
        }
    };

    subtest 'varying separator' => sub {
        my @tcs = (
            '1,2,3,4',
            '1, 2, 3, 4',
            '1, 2, 3, and 4',
            '1 and 2 and 3 and 4',
            '1 and 2 and 3, and 4',
        );
        my $expected = [1, 2, 3, 4];
        foreach my $tc (@tcs) {
            parse_test($tc, $expected);
        }
    };

    subtest 'item regex' => sub {
        my %tcs = (
            '\w' => {
                valid => {
                    '[1, 2, h]' => [1, 2, 'h'],
                },
                invalid => [
                    '[1, 2, hh]', '[?]',
                ],
            },
            '\d+' => {
                valid => {
                    '[11, 22, 3]' => [11, 22, 3],
                },
                invalid => [
                    '[a, 2, 3]',
                ],
            },
        );
        while (my ($re, $cases) = each %tcs) {
            subtest "regex: $re" => sub {
                subtest 'valid' => sub {
                    while (my ($tstring, $expected) = each %{$cases->{valid}}) {
                        parse_test($tstring, $expected, item => qr/$re/);
                    }
                };
                subtest 'invalid' => sub {
                    foreach my $invalid (@{$cases->{invalid}}) {
                        is(ListTester::parse_list($invalid, item => qr/$re/), undef, "parse $invalid");
                    }
                };
            };
        }
    };

    subtest 'nested' => sub {
        my %tcs = (
            '[1, [2, 3]]'   => {
                nested    => [1, [2, 3]],
                no_nested => [1, '[2', '3]'],
            },
            '[1, [2, [3]]]' => {
                nested    => [1, [2, [3]]],
                no_nested => [1, '[2', '[3]]'],
            },
            '[1, (2, 3)]'   => {
                nested    => [1, '(2', '3)'],
                no_nested => [1, '(2', '3)'],
            },
        );
        my %tests = (
            enabled             => ['nested', [qw(nested 1)]],
            disabled            => ['no_nested', [qw(nested 0)]],
            'default (enabled)' => ['nested', []],
        );
        while (my ($tname, $tc) = each %tests) {
            subtest $tname => sub {
                while (my ($ts, $tr) = each %tcs) {
                    parse_test($ts, $tr->{$tc->[0]}, @{$tc->[1]});
                }
            };
        }
        subtest 'defaults to off if item specified' => sub {
            subtest 'only item specified' => sub {
                parse_test_no('[1, 2, [3]]', item => qr/\d/);
            };
            subtest 'both item and nested specified' => sub {
                parse_test(
                    '[1, 2, [3]]', [1, 2, [3]],
                    item   => qr/\d/,
                    nested => 1,
                );
            };
        };
    };

    subtest 'invalid strings' => sub {
        my @tcs = (
            '',
            undef,
        );
        foreach my $tc (@tcs) {
            parse_test_no($tc);
        }
    };
};

subtest format_list => sub {
    subtest defaults => sub {
        my @tcs = (
            []           => '[]',
            [1]          => '[1]',
            [1, 2, 3, 4] => '[1, 2, 3, 4]',
        );

        foreach (pairs @tcs) {
            format_test(@$_);
        }
    };
    subtest 'parens' => sub {
        my @tcs = (
            '()' => [
                [1, 2, 3]   => '(1, 2, 3)',
                [1, [2, 3]] => '(1, (2, 3))',
            ],
            ['{', '}'] => [
                [1, 2, 3]   => '{1, 2, 3}',
                [1, [2, 3]] => '{1, {2, 3}}',
            ],
            '' => [
                [1, 2, 3]   => '1, 2, 3',
                [1, [2, 3]] => '1, 2, 3',
            ],
            '({})' => [
                [1, 2, 3]     => '(1, 2, 3)',
                [1, [2, 3]]   => '(1, {2, 3})',
                [1, [2, [3]]] => '(1, {2, {3}})',
            ],
            ['(', '{', '}', ')'] => [
                [1, 2, 3]     => '(1, 2, 3)',
                [1, [2, 3]]   => '(1, {2, 3})',
                [1, [2, [3]]] => '(1, {2, {3}})',
            ],
            '[{()}]' => [
                [1, 2, 3]     => '[1, 2, 3]',
                [1, [2, 3]]   => '[1, {2, 3}]',
                [1, [2, [3]]] => '[1, {2, (3)}]',
            ],
        );
        foreach (pairs @tcs) {
            my ($parens, $cases) = @$_;
            my $to_show = ref $parens eq 'ARRAY'
                ? join(', ', @$parens) : $parens;
            subtest "parens: $to_show" => sub {
                foreach (pairs @$cases) {
                    my ($case, $expected) = @$_;
                    format_test(
                        $case, $expected, parens => $parens
                    );
                }
            };
        }
    };
    subtest join => sub {
        my %tcs = (
            ', '    => '1, 2, 3',
            ' and ' => '1 and 2 and 3',
        );
        while (my ($join, $expected) = each %tcs) {
            format_test([1, 2, 3], $expected,
                parens => '',
                join   => $join,
            );
        };
    };
    subtest join_last => sub {
        my @tcs = (
            [1, 2, 3]   => '[1, 2, and 3]',
            [1, [2, 3]] => '[1, and [2, and 3]]',
        );
        foreach (pairs @tcs) {
            my ($case, $expected) = @$_;
            format_test($case, $expected,
                join_last => ', and ',
            );
        }
    };
};

done_testing;

1;
