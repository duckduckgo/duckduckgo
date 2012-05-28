package DDG::Meta::Attribution;

use strict;
use warnings;
use Carp qw( croak );
use Package::Stash;

require Moo::Role;

my %supported_types = (
	email => [ 'mailto:{{a}}', '{{b}}' ],
	twitter => [ 'https://twitter.com/{{a}}', '@{{b}}' ],
	web => [ '{{a}}', '{{b}}' ],
	github => [ 'https://github.com/{{a}}', '{{b}}' ],
	facebook => [ 'https://facebook.com/{{a}}', '{{b}}' ],
	cpan => [ 'https://metacpan.org/author/{{a}}', '{{a}}' ],
);

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my @attributions;

	my $stash = Package::Stash->new($target);

	$stash->add_symbol('&get_attributions', sub {
		my @attribution_links;
		for (@attributions) {
			my $type = shift @{$_};
			my $value = shift @{$_};
			my ( $a, $b ) = ref $value eq 'ARRAY' ? ( $value->[0], $value->[1] ) : ( $value, $value );
			my ( $link, $val ) = @{$supported_types{$type}};
			$link =~ s/{{a}}/$a/;
			$link =~ s/{{b}}/$b/;
			$val =~ s/{{a}}/$a/;
			$val =~ s/{{b}}/$b/;
			push @attribution_links, $link, $val;
		}
		return \@attribution_links;
	});
	$stash->add_symbol('&get_attributions_html', sub {
		# TODO
	});
	$stash->add_symbol('&attribution', sub {
		while (@_) {
			my $type = shift;
			my $value = shift;
			croak $type." is not a valid attribution type (Supported: ".join(',',keys %supported_types).")"
				unless grep { $_ eq $type } keys %supported_types;
			push @attributions, [ $type, $value ];
		}
	});

	#
	# apply role
	#

	Moo::Role->apply_role_to_package($target,'DDG::HasAttribution');

}

1;
