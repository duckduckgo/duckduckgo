package DDG::Block::Blockable;

use Moo::Role;

requires qw(
	get_triggers
);

has block => (
	is => 'ro',
	required => 1,
);

1;