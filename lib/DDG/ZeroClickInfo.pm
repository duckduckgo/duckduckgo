package DDG::ZeroClickInfo;
# ABSTRACT: DuckDuckGo server side used ZeroClickInfo class

=head1 SYNOPSIS

  my $zci = DDG::ZeroClickInfo->new(
    answer => "I'm a little teapot!",
    is_cached => 1,
    ttl => 500,
  );

=head1 DESCRIPTION

This is the extension of the L<WWW::DuckDuckGo::ZeroClickInfo> class, how it is used on the server side of DuckDuckGo.
It adds attributes to the ZeroClickInfo class which are not required for the "output" part of it.

=cut

use Moo;
extends qw( WWW::DuckDuckGo::ZeroClickInfo );
with 'DDG::IsControllable';

=head1 SEE ALSO

L<WWW::DuckDuckGo::ZeroClickInfo>

=cut

1;