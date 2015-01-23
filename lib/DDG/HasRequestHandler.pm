package DDG::HasRequestHandler;
# ABSTRACT: Role for a plugin that has a request handler

use Moo::Role;

requires qw(
	handle_request_matches
);

=head1 DESCRIPTION

This role is for plugins which have a request handler. They need to implement a
B<handle_request_matches> function.

Please see L<DDG::Meta::RequestHandler> and L<DDG::Meta> for more information.

=cut

1;