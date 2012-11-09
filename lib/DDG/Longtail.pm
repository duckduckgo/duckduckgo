package DDG::Longtail;
# ABSTRACT: Longtail package for easy keywords

use strict;
use warnings;
use DDG::Meta;

sub import {
	my ( $class ) = @_;
	my $target = caller;

	DDG::Meta->apply_base_to_package($target);
	DDG::Meta->apply_longtail_keywords($target);
}

=head1 SYNOPSIS

  package DDG::Longtail::MyLongtail;
  # ABSTRACT: My cool Longtail!

  use DDG::Longtail;

  1;

=head1 DESCRIPTION

This is the Longtail Meta class. It injects all the keywords used for
ZeroClickInfo Longtail. For more information see L<DDG::Meta>.

=head1 SEE ALSO

L<http://duckduckhack.com/>

=cut

1;
