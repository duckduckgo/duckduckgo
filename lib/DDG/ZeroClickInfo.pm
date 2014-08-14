package DDG::ZeroClickInfo;
# ABSTRACT: DuckDuckGo server side used ZeroClickInfo result class

use Moo;
extends qw( WWW::DuckDuckGo::ZeroClickInfo );

=head1 SYNOPSIS

  my $zci = DDG::ZeroClickInfo->new(
    answer => "I'm a little teapot!",
    is_cached => 1,
    ttl => 500,
  );

=head1 DESCRIPTION

This is the extension of the L<WWW::DuckDuckGo::ZeroClickInfo> class, how it
is used on the server side of DuckDuckGo. It adds attributes to the
ZeroClickInfo class which are not required for the client side usage.

So far all required attributes get injected via L<DDG::IsControllable>.

=cut

has structured_result => (
    is        => 'ro',
    predicate => 1,
);

with 'DDG::IsControllable', 'DDG::IsStructurable';

=head1 SEE ALSO

L<WWW::DuckDuckGo::ZeroClickInfo>

=cut

1;
