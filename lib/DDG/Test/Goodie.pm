package DDG::Test::Goodie;

use strict;
use warnings;
use Carp;
use DDG::Request;
use DDG::ZeroClickInfo;
use DDG::Meta::ZeroClickInfo;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	DDG::Meta::ZeroClickInfo->apply_keywords($target);
	*{"${target}::zci"}->( is_cached => 0 );

	{
		my $triggers;
		no strict "refs";

		*{"${target}::ddg_goodie_test"} = sub {
			while (@_) {
				my $query = shift;
				my $zci = shift;
			}
		};
	}

}

1;


1;