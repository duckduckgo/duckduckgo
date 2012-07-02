package DDG::IsControllable;

use Moo::Role;

has is_cached => (
	is => 'ro',
	default => sub { shift->isa("DDG::ZeroClickInfo::Spice") ? 1 : 0 },
);

has is_unsafe => (
	is => 'ro',
	default => sub { 0 },
);

has ttl => (
	is => 'ro',
	predicate => 'has_ttl',
);

1;