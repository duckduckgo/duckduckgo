package DDG::Meta::Helper;
# ABSTRACT: Inject some helper keywords

use strict;
use warnings;
use Carp qw( croak );
use Package::Stash;
use HTML::Entities;
use URI::Escape;

=head1 SYNOPSIS

On your goodie for example:

  return "text from random source: ".$text."!",
    html => "<div>text from random source: ".html_enc($text)."!</div>";

=head1 DESCRIPTION

This meta class installs the functions B<html_enc> and B<uri_esc>.

=keyword html_enc

encodes entities to safely post random data on HTML output.

=keyword uri_esc

Encodes entities to safely use it in URLs for links in the Goodie, for
example.

B<Warning>: Do not forget that the return value from a spice will
automatically get url encoded for the path. It is not required to url encode
values there, this will just lead to double encoding!

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my $stash = Package::Stash->new($target);

	$stash->add_symbol('&html_enc', sub { map { encode_entities($_) } @_ });
	$stash->add_symbol('&uri_esc', sub { map { uri_escape($_) } @_ });

}

1;
