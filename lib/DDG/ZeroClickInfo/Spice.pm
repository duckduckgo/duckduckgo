package DDG::ZeroClickInfo::Spice;

use Moo;

has js => (
	is => 'ro',
	required => 1,
);

has js_root => (
	is => 'ro',
	required => 1,
);

has js_includes => (
	is => 'ro',
	default => sub {[]},
);

has is_cached => (
	is => 'ro',
	default => sub { 0 },
);

1;