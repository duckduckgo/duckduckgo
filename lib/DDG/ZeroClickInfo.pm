package DDG::ZeroClickInfo;

=head1 SYNOPSIS

  my $zci = DDG::ZeroClickInfo->new(
    answer => "I'm a little teapot!",
    is_cached => 1,
    ttl => 500,
  );

=head1 DESCRIPTION

This is the extension of the WWW::DuckDuckGo::ZeroClickInfo class, how it is used on the server side of DuckDuckGo.
It adds attributes to the ZeroClickInfo class which are not required for the "output" part of it.

=cut

use Moo;
extends qw( WWW::DuckDuckGo::ZeroClickInfo );

=head1 ATTRIBUTES

=head2 is_cached

This attribute sets if the ZeroClickInfo should get cached on the caching layer of DuckDuckGo

=cut

has is_cached => (
	is => 'ro',
	default => sub { 0 },
);

=head2 ttl

The TTL defines how long this data should get cached

=cut

has ttl => (
	is => 'ro',
	predicate => 'has_ttl',
);

1;

=head1 SEE ALSO

L<WWW::DuckDuckGo::ZeroClickInfo>

