package DDG::Meta;

use strict;
use warnings;
use Carp;

use DDG::Meta::Block;
use DDG::Meta::Goodie;
use DDG::Meta::Spice;
use DDG::Meta::ZeroClickInfo;

sub apply_base_to_package {
	my ( $class, $target ) = @_;
	
	eval qq{
		package $target;
		use Moo;
		use Data::Printer;
	};
}

sub apply_block_keywords {
	my ( $class, $target ) = @_;
	DDG::Meta::Block->apply_keywords($target);
}

sub apply_goodie_keywords {
	my ( $class, $target ) = @_;
	DDG::Meta::Goodie->apply_keywords($target);
}

sub apply_spice_keywords {
	my ( $class, $target ) = @_;
	DDG::Meta::Spice->apply_keywords($target);
}

sub apply_zci_keywords {
	my ( $class, $target ) = @_;
	DDG::Meta::ZeroClickInfo->apply_keywords($target);
}

1;