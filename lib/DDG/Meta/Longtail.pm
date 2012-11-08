package DDG::Meta::Longtail;
# ABSTRACT: Functions for generating a L<DDG::ZeroClickInfo::Longtail> factory 

use strict;
use warnings;
use Package::Stash;

sub longtail_attributes {qw(
)}

=head1 DESCRIPTION

=cut

=method apply_keywords

Uses a given classname to install the described keywords.

=cut

my %applied;

sub apply_keywords {
    my ( $class , $target ) = @_;

    return if exists $applied{$target};
    $applied{$target} = undef;

    my @parts = split( '::' , $target );
    shift @parts;
    shift @parts;
    my $answer_type = lc(join(' ', @parts));

    my $stash = Package::Stash->new($target);

    my %zci_params = (
        answer_type => $answer_type,
    );

=keyword longtail

=cut

    $stash->add_symbol('&zci', sub {
        if (ref $_[0] eq 'HASH') {
            for (keys %{$_[0]}) {
                $zci_params{check_longtail_key($_)} = $_[0]->{$_};
            }
        } else {
            while (@_) {
                my $key = shift;
                my $value = shift;
                $zci_params{check_longtail_key($key)} = $value;
            }
        }
    });
}

1;
