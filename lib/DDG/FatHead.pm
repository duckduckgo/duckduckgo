package DDG::FatHead;
# ABSTRACT: FatHead package for easy keywords

use strict;
use warnings;
use DDG::Meta;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	DDG::Meta->apply_base_to_package($target);
	DDG::Meta->apply_fathead_keywords($target);
}

=head1 SYNOPSIS

  package DDG::FatHead::MyFatHead;
  # ABSTRACT: My cool FatHead!

  use DDG::FatHead;

  1;

=head1 DESCRIPTION

This is the FatHead Meta class. It injects all the keywords used for
ZeroClickInfo FatHead. For more information see L<DDG::Meta>.

=head1 SEE ALSO

L<http://duckduckhack.com/>

=cut

1;
