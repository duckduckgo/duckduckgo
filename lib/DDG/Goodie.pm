package DDG::Goodie;
# ABSTRACT: Goodie package for easy keywords

use strict;
use warnings;
use Carp;
use DDG::Meta;

=head1 DESCRIPTION

This is the Goodie Meta class. It injects all the keywords used for
ZeroClickInfo Goodies. For more information see L<DDG::Meta>.

=cut

sub import {
	my ( $class ) = @_;
	my $target = caller;

	#
	# Make base
	#

	DDG::Meta->apply_base_to_package($target);
	
	#
	# Apply keywords
	#

	DDG::Meta->apply_goodie_keywords($target);
	
}

1;
