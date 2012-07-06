package DDG::IsControllable;
# ABSTRACT: Role for data managed inside the DuckDuckGo infrastructure

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

=head1 DESCRIPTION

This role is used for classes which should be cacheable or marked as safe or
unsafe for kids.

=cut

1;