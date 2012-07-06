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

B<html_enc> encodes entities to safely post random data on HTML output.

B<uri_esc> encodes entities to safely use it in URLs for links in the Goodie,
for example.

=cut

my %applied;

=method apply_keywords

Uses a given classname to install the described keywords.

=cut

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my $stash = Package::Stash->new($target);

	$stash->add_symbol('&html_enc', sub { map { encode_entities($_) } @_ });
	$stash->add_symbol('&uri_esc', sub { map { uri_escape($_) } @_ });

}

1;
