#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

subtest 'Initialization' => sub {
	use DDG::Util::NumberStyler;
	isa_ok(number_style_regex(), 'Regexp', 'number_style_regex()');
};

subtest 'Valid numbers' => sub {

	my @valid_test_cases = (
		[['0,013'] => 'euro'],
		[['4,431',      '4.321'] => 'perl'],
		[['4,431',      '4,32']  => 'euro'],
		[['4534,345.0', '1']     => 'perl'],    # Unenforced commas.
		[['4,431',     '4,32', '5,42']       => 'euro'],
		[['4,431',     '4.32', '5.42']       => 'perl'],
		[['4_431_123', '4 32', '99.999 999'] => 'perl'],
		[['4e1', '-1e25', '4.5e-25'] => 'perl'],
		[['-1,1e25', '4,5e-25'] => 'euro'],
		[['4E1', '-1E25', '4.5E-25'] => 'perl'],
		[['-1,1E25', '4,5E-25'] => 'euro'],
	);

	my $number_style_regex = number_style_regex();
	foreach my $tc (@valid_test_cases) {
		my @numbers           = @{$tc->[0]};
		my $expected_style_id = $tc->[1];
		is(number_style_for(@numbers)->id,
			$expected_style_id, '"' . join(' ', @numbers) . '" yields a style of ' . $expected_style_id);
		like($_, qr/^$number_style_regex$/, "$_ matches the number_style_regex") for(@numbers);
	}
};

subtest 'Invalid numbers' => sub {
	my @invalid_test_cases = (
		[['5234534.34.54', '1'] => 'has a mal-formed number'],
		[['4,431',     '4,32',     '4.32']       => 'is confusingly ambiguous'],
		[['4,431',     '4.32.10',  '5.42']       => 'is hard to figure'],
		[['4,431',     '4,32,100', '5.42']       => 'has a mal-formed number'],
		[['4,431',     '4,32,100', '5,42']       => 'is too crazy to work out'],
		[['4_431_123', "4\t32",    '99.999 999'] => 'no tabs in numbers'],
	);

	foreach my $tc (@invalid_test_cases) {
		my @numbers = @{$tc->[0]};
		my $why_not = $tc->[1];
		is(number_style_for(@numbers), undef, '"' . join(' ', @numbers) . '" fails because it ' . $why_not);
	}
};

done_testing;

1;
