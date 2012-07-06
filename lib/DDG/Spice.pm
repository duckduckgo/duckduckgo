package DDG::Spice;
# ABSTRACT: Spice package for easy keywords

use strict;
use warnings;
use DDG::Meta;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	DDG::Meta->apply_base_to_package($target);
	DDG::Meta->apply_spice_keywords($target);
}

=head1 SYNOPSIS

  package DDG::Spice::MySpice;
  # ABSTRACT: My cool spice!

  use DDG::Spice;

  triggers startend => "cool";
  spice to => 'http://ownage.cool/?t=$1&callback={{callback}}';

  handle remainder => sub { $_ ? $_ : "" };

  1;

=head1 DESCRIPTION

This is the Spice Meta class. It injects all the keywords used for
ZeroClickInfo Spice. For more information see L<DDG::Meta>.

Use the B<server> command of L<App::DuckPAN> for testing your spice!

=head1 SEE ALSO

L<http://duckduckhack.com/>

=cut

1;