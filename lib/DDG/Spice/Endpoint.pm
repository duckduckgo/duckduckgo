package DDG::Spice::Endpoint;
# ABSTRACT: Spice package for easy keywords

use strict;
use warnings;
use DDG::Meta;

sub import {
	my ( $class ) = @_;
	my $target = caller;

	DDG::Meta->apply_base_to_package($target);
	DDG::Meta->apply_spice_endpoint_keywords($target);
}

=head1 SYNOPSIS

  package DDG::Spice::MySpice;
  # ABSTRACT: My cool spice!

  use DDG::Spice::Endpoint;

  # No Triggers
   
  spice to => 'http://ownage.cool/?t=$1&callback={{callback}}';
  
  # No Handle either
 
  1;

=head1 DESCRIPTION

This is the Spice Endpoint Meta class. It injects the the to and from keywords used for
ZeroClickInfo Spice. For more information see L<DDG::Meta>.

Use the B<server> command of L<App::DuckPAN> for testing your spice!

=head1 SEE ALSO

L<http://duckduckhack.com/>

=cut

1;
