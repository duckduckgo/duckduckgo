package DDG::Fathead;
# ABSTRACT: Fathead package for easy keywords

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

  package DDG::Fathead::MyFathead;
  # ABSTRACT: My cool Fathead!

  use DDG::Fathead;

  1;

=head1 DESCRIPTION

This is the Fathead Meta class. It injects all the keywords used for
ZeroClickInfo Fathead. For more information see L<DDG::Meta>.

=head1 SEE ALSO

L<http://duckduckhack.com/>

=cut

1;
