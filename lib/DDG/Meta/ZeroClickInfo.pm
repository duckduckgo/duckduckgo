package DDG::Meta::ZeroClickInfo;
# ABSTRACT: Functions for generating a L<DDG::ZeroClickInfo> factory

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo;
use Package::Stash;

my %supported_zci_attributes = map { $_ => 1 } (qw(
      abstract
      abstract_text
      abstract_source
      abstract_url
      caller
      image
      heading
      answer
      answer_type
      definition
      definition_source
      definition_url
      type
      is_cached
      is_unsafe
      ttl
));

=head1 DESCRIPTION

=cut

=method apply_keywords

Uses a given classname to install the described keywords.

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my @parts = split('::',$target);
	shift @parts;
	shift @parts;
	my $answer_type = lc(join(' ',@parts));

	my $stash = Package::Stash->new($target);

	my %zci_params = (
        caller      => $target,
		answer_type => $answer_type,
	);

=keyword zci

This function applies default parameter to the L<DDG::ZeroClickInfo> that you
can generate via L</zci_new>. All keys given are checked through a list of
possible L<DDG::ZeroClickInfo> attributes.

  zci is_cached => 1;
  zci answer_type => 'random';

=cut


    $stash->add_symbol( '&zci', sub {
            my %kv = (ref $_[0] eq 'HASH') ? %{$_[0]} : @_;
            while (my ($key, $value) = each(%kv)) {
                croak $key. " is not supported on DDG::ZeroClickInfo" unless (exists $supported_zci_attributes{$key});
                $zci_params{$key} = $value;
            }
        });

=keyword zci_new

This function gives back a L<DDG::ZeroClickInfo> set with the parameter given
on L</zci> and then overridden and extended through the parameter given to
this function.

=cut

	$stash->add_symbol('&zci_new', sub {
		shift;
		DDG::ZeroClickInfo->new( %zci_params, ref $_[0] eq 'HASH' ? %{$_[0]} : @_ );
	});

}

1;
