package DDG::Meta::AnyBlock;
# ABSTRACT: Implement L<DDG::Block::Blockable::Any> to the plugin

use strict;
use warnings;
use Carp;
require Moo::Role;

=head1 DESCRIPTION

=method apply_keywords

Adds the role L<DDG::Block::Blockable::Any> to the target classname. It's
named I<apply_keywords> to be the same as in the other meta classes which
actually really install keywords.

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	Moo::Role->apply_role_to_package($target,'DDG::Block::Blockable::Any');

}

1;
