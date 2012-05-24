package DDG::Meta::Helper;

use strict;
use warnings;
use Carp qw( croak );
use Package::Stash;
use HTML::Entities;
use URI::Escape;

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
