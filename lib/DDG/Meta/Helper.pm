package DDG::Meta::Helper;
# ABSTRACT: Helper functions for easy access to important functions

use strict;
use warnings;
use Carp qw( croak );
use Package::Stash;
use HTML::Entities;
use URI::Escape;
use Data::Entropy::Algorithms qw(rand_int);

=head1 SYNOPSIS

In your goodie, for example:

  return "text from random source: ".$text."!",
    html => "<div>text from random source: ".html_enc($text)."!</div>";

Or use JSON-like booleans:

  { option1 => true, option2 => false }

=head1 DESCRIPTION

This meta class installs some helper functions.

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my $stash = Package::Stash->new($target);

=keyword html_enc

encodes entities to safely post random data on HTML output.

=cut

	$stash->add_symbol('&html_enc', sub { return (wantarray) ? map { encode_entities($_) } @_ : encode_entities(join '', @_) });

=keyword uri_esc

Encodes entities to safely use it in URLs for links in the Goodie, for
example.

B<Warning>: Do not forget that the return value from a spice will
automatically get url encoded for the path. It is not required to url encode
values there, this will just lead to double encoding!

=cut

	$stash->add_symbol('&uri_esc', sub { return (wantarray) ? map { uri_escape($_) } @_ : uri_escape(join '', @_) });

=keyword Booleans (true/false)

Use booleans true and false to set options.

=cut

    $stash->add_symbol('&true', sub { 1 });
    $stash->add_symbol('&false', sub { 0 });

=keyword rand_int

generates random integer between 0 and supplied max integer (max defaults to 1).

=cut

	$stash->add_symbol('&rand_int', sub { 	
		my $max = shift || 1;
		return rand_int($max);
	});
}

1;
