package DDG::Query;

use Moo;

has query => (
	is => 'ro',
	required => 1,
);

1;