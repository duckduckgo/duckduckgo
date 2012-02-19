package DDG::Meta;

use strict;
use warnings;
use Carp;

use DDG::Meta::RequestHandler;
use DDG::Meta::ZeroClickInfo;
use DDG::Meta::Block;

sub apply_base_to_package {
	my ( $class, $target ) = @_;
	
	eval qq{
		package $target;
		use Moo;
		use Data::Printer;
	};
}

sub apply_goodie_keywords {
	my ( $class, $target ) = @_;
	DDG::Meta::ZeroClickInfo->apply_keywords($target);
	DDG::Meta::Block->apply_keywords($target);
	DDG::Meta::RequestHandler->apply_keywords($target,sub { shift->zci_new( answer => shift ) });
}

sub apply_spice_keywords {
	my ( $class, $target ) = @_;
	DDG::Meta::ZeroClickInfo->apply_keywords($target);
	DDG::Meta::Block->apply_keywords($target);
	DDG::Meta::RequestHandler->apply_keywords($target,sub { "TODO" });
}

1;