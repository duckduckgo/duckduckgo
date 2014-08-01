package DDG::IsStructurable;
# ABSTRACT: Role for adding structured data to query results.

use Moo::Role;

requires qw(
  structured_result
);

=head1 DESCRIPTION

This role is used for classes which can return structured data in results for queries.

=attr structured_result

Indicates whether the package can provide a structured result.

=cut

has structured => (
    is      => 'ro',
    default => sub { 0 },
);

1;
