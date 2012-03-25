package DDG::ZeroClickInfo;

use Moo;
extends qw( WWW::DuckDuckGo::ZeroClickInfo );

has is_cached => (
	is => 'ro',
	default => sub { 0 },
);

has ttl => (
	is => 'ro',
	predicate => 'has_ttl',
);

1;