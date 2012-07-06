package DDG::ZeroClickInfo::Spice;
# ABSTRACT: DuckDuckGo server side used ZeroClickInfo Spice result class

use Moo;
with 'DDG::IsControllable';


=head1 SYNOPSIS

  my $zci_spice = DDG::ZeroClickInfo::Spice->new(
    caller => 'DDGTest::Spice::SomeThing',
    call => '/js/spice/some_thing/a%23%23a/b%20%20b/c%23%3F%3Fc',
  );

=head1 DESCRIPTION

This is the extension of the L<WWW::DuckDuckGo::ZeroClickInfo> class, how it
is used on the server side of DuckDuckGo. It adds attributes to the
ZeroClickInfo class which are not required for the "output" part of it.

It is also a L<DDG::IsControllable>.

=attr call

The URL on DuckDuckGo that should be called for the spice. It is not required
to set a call.

=cut

has call => (
	is => 'ro',
	predicate => 'has_call',
);

has call_type => (
	is => 'ro',
	predicate => 'has_call_type',
);

=attr caller

Must be set with the class generating the spice result for fetching additional
configuration from there.

=cut

has caller => (
	is => 'ro',
	required => 1,
);

# LEGACY
sub call_path { shift->call }

1;