package DDG::Block::Blockable::Any;
# ABSTRACT: A package which reflects a blockable plugin with no triggers.

use Moo;
use Carp;

has triggers => (
	is => 'ro',
	default => sub {{}}
);

has block_type => (
	is => 'rw',
	predicate => 'has_block_type',
	default => sub { 'Any' }
);

sub get { return; }

1;
