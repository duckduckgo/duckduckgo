package DDG::Meta::Fathead;
# ABSTRACT: Functions for generating a L<DDG::ZeroClickInfo::Fathead> factory 

use strict;
use warnings;
use Package::Stash;

sub fathead_attributes {qw(
    mediawiki
    title_addon
)}

=head1 DESCRIPTION

=cut

=method apply_keywords

Uses a given classname to install the described keywords.

=cut

sub apply_keywords {
    my ( $class , $target ) = @_;

    my @parts = split( '::' , $target );
    shift @parts;
    shift @parts;
    my $answer_type = lc(join(' ', @parts));

    my $stash = Package::Stash->new($target);

    my %zci_params = (
        answer_type => $answer_type,
    );

=keyword fathead

=cut

    $stash->add_symbol('&fathead', sub {
        if (ref $_[0] eq 'HASH') {
            for (keys %{$_[0]}) {
                $zci_params{check_fathead_key($_)} = $_[0]->{$_};
            }
        } else {
            while (@_) {
                my $key = shift;
                my $value = shift;
                $zci_params{check_fathead_key($key)} = $value;
            }
        }
    });
}

=method check_fathead_key

=cut

sub check_fathead_key {
    my $key = shift;
    if (grep { $key eq $_ } fathead_attributes) {
        return $key;
    } else {
        croak $key." is not supported on DDG::Meta::Fathead";
    }
}

1;
