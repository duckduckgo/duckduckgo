package DDG::GoodieRole::NumberStyle;
# ABSTRACT: An object representing a particular numerical notation.

use strict;
use warnings;

use Moo;
use Math::BigFloat;

has [qw(id decimal thousands)] => (
    is => 'ro',
);

has exponential => (
    is      => 'ro',
    default => sub { 'e' },
);

has number_regex => (
    is => 'lazy',
);

sub _build_number_regex {
    my $self = shift;
    my ($decimal, $thousands, $exponential) = ($self->decimal, $self->thousands, $self->exponential);

    return qr/-?[\d_ \Q$decimal\E\Q$thousands\E]+(?:\Q$exponential\E-?\d+)?/i;
}

sub understands {
    my ($self, $number) = @_;
    my ($decimal, $thousands) = ($self->decimal, $self->thousands);

    # How do we know if a number is reasonable for this style?
    # This assumes the exponentials are not included to give better answers.
    return (
        # The number must contain only things we understand: numerals and separators for this style.
        $number =~ /^-?(|\d|_| |\Q$thousands\E|\Q$decimal\E)+$/
          && (
            # The number is not required to contain thousands separators
            $number !~ /\Q$thousands\E/
            || (
                # But if the number does contain thousands separators, they must delimit exactly 3 numerals.
                $number !~ /\Q$thousands\E\d{1,2}\b/
                && $number !~ /\Q$thousands\E\d{4,}/
                # And cannot follow a leading zero
                && $number !~ /^0\Q$thousands\E/
            ))
          && (
            # The number is not required to include decimal separators
            $number !~ /\Q$decimal\E/
            # But if one is included, it cannot be followed by another separator, whether decimal or thousands.
            || $number !~ /\Q$decimal\E(?:.*)?(?:\Q$decimal\E|\Q$thousands\E)/
          )) ? 1 : 0;
}

sub precision_of {
    my ($self, $number_text) = @_;
    my $decimal = $self->decimal;

    return ($number_text =~ /\Q$decimal\E(\d+)/) ? length($1) : 0;
}

sub for_computation {
    my ($self, $number_text) = @_;
    my ($decimal, $thousands, $exponential) = ($self->decimal, $self->thousands, $self->exponential);

    $number_text =~ s/[ _]//g;              # Remove spaces and underscores as visuals.
    $number_text =~ s/\Q$thousands\E//g;    # Remove thousands seps, since they are just visual.
    $number_text =~ s/\Q$decimal\E/./g;     # Make sure decimal mark is something perl knows how to use.
    if ($number_text =~ s/^([\d$decimal$thousands]+)\Q$exponential\E(-?[\d$decimal$thousands]+)$/$1e$2/ig) {
        # Convert to perl style exponentials and then make into human-style floats.
        $number_text = Math::BigFloat->new($number_text)->bstr();
    }

    return $number_text;
}

sub for_display {
    my ($self, $number_text) = @_;
    my ($decimal, $thousands, $exponential) = ($self->decimal, $self->thousands, $self->exponential);

    $number_text =~ s/[ _]//g;    # Remove spaces and underscores as visuals.
    if ($number_text =~ /(.*)\Q$exponential\E([+-]?\d+)/i) {
        $number_text = $self->for_display($1) . ' * 10^' . $self->for_display(int $2);
    } else {
        $number_text = reverse $number_text;
        $number_text =~ s/\./$decimal/g;    # Perl decimal mark to whatever we need.
        $number_text =~ s/(\d{3})(?=\d)(?!\d*\Q$decimal\E)/$1$thousands/g;
        $number_text = reverse $number_text;
    }

    return $number_text;
}

# The display version with HTML added:
# - superscripted exponents
sub with_html {
    my ($self, $number_text) = @_;

    return $self->_add_html_exponents($number_text);
}

sub _add_html_exponents {

    my ($self, $string) = @_;

    return $string if ($string !~ /\^/ or $string =~ /^\^|\^$/);    # Give back the same thing if we won't deal with it properly.

    my @chars = split //, $string;
    my $number_re = $self->number_regex;
    my ($start_tag, $end_tag) = ('<sup>', '</sup>');
    my ($newly_up, $in_exp_number, $in_exp_parens, %power_parens);
    my ($parens_count, $number_up) = (0, 0);

    # because of associativity and power-to-power, we need to scan nearly the whole thing
    for my $index (1 .. $#chars) {
        my $this_char = $chars[$index];
        if ($this_char =~ $number_re or ($newly_up && $this_char eq '-')) {
            if ($newly_up) {
                $in_exp_number = 1;
                $newly_up      = 0;
            }
        } elsif ($this_char eq '(') {
            $parens_count += 1;
            $in_exp_number = 0;
            if ($newly_up) {
                $in_exp_parens += 1;
                $power_parens{$parens_count} = 1;
                $newly_up = 0;
            }
        } elsif ($this_char eq '^') {
            $chars[$index - 1] =~ s/$end_tag$//;    # Added too soon!
            $number_up += 1;
            $newly_up      = 1;
            $chars[$index] = $start_tag;            # Replace ^ with the tag.
        } elsif ($in_exp_number) {
            $in_exp_number = 0;
            $number_up -= 1;
            $chars[$index] = $end_tag . $chars[$index];
        } elsif ($number_up && !$in_exp_parens) {
            # Must have ended another term or more
            $chars[$index] = ($end_tag x $number_up) . $chars[$index];
            $number_up -= 1;
        } elsif ($this_char eq ')') {
            # We just closed a set of parens, see if it closes one of our things
            if ($in_exp_parens && $power_parens{$parens_count}) {
                $chars[$index] .= $end_tag;
                delete $power_parens{$parens_count};
                $in_exp_parens -= 1;
                $number_up     -= 1;
            }
            $parens_count -= 1;
        }
    }
    my $final = join('', @chars);
    # We may not have added enough closing tags, because we can't "see" the end.
    my $up_count   = () = $final =~ /$start_tag/g;
    my $down_count = () = $final =~ /$end_tag/g;
    # We'll assume we're just supposed to append them now
    $final .= $end_tag x ($up_count - $down_count);

    return $final;
}

1;
