package DDG::IsControllable;
# ABSTRACT: Role for data managed inside the DuckDuckGo infrastructure

use Moo::Role;

=head1 DESCRIPTION

This role is used for classes which should be cacheable or marked as safe or
unsafe for kids.

=cut

=attr is_cached

Defines if the data should get cached. Default on for spice, default off for
anything else.

=cut

has is_cached => (
	is => 'ro',
	default => sub { shift->isa("DDG::ZeroClickInfo::Spice") ? 1 : 0 },
);

=attr is_unsafe

Define that this data might not be appropiate for underage.

=cut

has is_unsafe => (
	is => 'ro',
	default => sub { 0 },
);

=attr ttl

If the data is cached, which time to life for the data should be set. If none
is given, then unlimited cachetime will be assumed.

=cut

has ttl => (
	is => 'ro',
	predicate => 'has_ttl',
);

1;