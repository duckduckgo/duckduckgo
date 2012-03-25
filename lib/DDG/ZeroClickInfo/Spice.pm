package DDG::ZeroClickInfo::Spice;

use Moo;

has call => (
	is => 'ro',
	required => 1,
);

has caller => (
	is => 'ro',
	required => 1,
);

has is_cached => (
	is => 'ro',
	default => sub { 1 },
);

1;