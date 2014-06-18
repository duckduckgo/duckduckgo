package DDG::Region;
# ABSTRACT: A region, can be empty [TODO]

use Moo;

my @region_attributes = qw();

has $_ => (
  is => 'ro',
  default => sub { '' }
) for (@region_attributes);

1;