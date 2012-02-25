package DDG::Block::Blockable;

use Moo::Role;

has block => (
	is => 'ro',
	required => 1,
);

1;