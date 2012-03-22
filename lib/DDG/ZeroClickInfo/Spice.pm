package DDG::ZeroClickInfo::Spice;

use Moo;

has js_includes => (
	is => 'ro',
	default => sub {[]},
);

has js => (
	is => 'ro',
	required => 1,
);

has is_memcached => (
	is => 'ro',
	default => sub { 0 },
);

1;