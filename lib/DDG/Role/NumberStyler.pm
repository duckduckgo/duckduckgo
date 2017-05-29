package DDG::GoodieRole::NumberStyler;
# ABSTRACT: A role to allow Goodies to recognize and work with numbers in different notations.

use strict;
use warnings;

use Moo::Role;
use DDG::GoodieRole::NumberStyle;

use List::Util qw( all first );

# If it could fit more than one the first in order gets preference.
my @known_styles = (
    DDG::GoodieRole::NumberStyle->new({
            id        => 'perl',
            decimal   => '.',
            thousands => ',',
        }
    ),
    DDG::GoodieRole::NumberStyle->new({
            id        => 'euro',
            decimal   => ',',
            thousands => '.',
        }
    ),
);

sub number_style_regex {
    my $return_regex = join '|', map { $_->number_regex } @known_styles;
    return qr/$return_regex/;
}

# Takes an array of numbers and returns which style to use for parse and display
# If there are conflicting answers among the array, will return undef.
sub number_style_for {
    my @numbers = @_;

    my $style;    # By default, assume we don't understand the numbers.

    STYLE:
    foreach my $test_style (@known_styles) {
        my $exponential = lc $test_style->exponential;    # Allow for arbitrary casing.
        if (all { $test_style->understands($_) } map { split /$exponential/, lc $_ } @numbers) {
            # All of our numbers fit this style.  Since we have them in preference order
            # we can pick it and move on.
            $style = $test_style;
            last STYLE;
        }
    }

    return $style;
}

1;
