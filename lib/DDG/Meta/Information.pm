package DDG::Meta::Information;

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

my @supported_categories = qw(
	bang
	calculations
	cheat_sheets
	computing_info
	computing_tools
	conversions
	dates
	entertainment
	facts
	finance
	food
	formulas
	forums
	geography
	ids
	language
	location_aware
	physical_properties
	programming
	q/a
	random
	reference
	software
	time_sensitive
	transformations
);

my @supported_topics = qw(
	everyday_goodies
	economy_and_finance
	cryptography
	entertainment
	food_and_drink
	gaming
	geek
	geography
	math 
	music
	programming
	science
	social
	special_intererst
	sysadmin
	travel
	trivia
	web_design
	words_and_games
);

=head1 DESCRIPTION

TODO

=method apply_keywords

Uses a given classname to install the described keywords.

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;

	my @attributions;
	my @topics;
	my $example_query;
	my @secondary_example_queries;
	my $icon;
	my $category;
	my $name;
	my $icon_url;
	my $code_url;
	my $url_regex = url_match_regex();

	my $stash = Package::Stash->new($target);

=keyword category

This function sets the category for the plugin. Plugins are only allowed one category.

=cut

	$stash->add_symbol('&category', sub {
		croak "Only one category allowed."
			unless scalar @_ == 1;
		my $value = shift;
		croak $value." is not a valid category (Supported: ".join(',',@supported_categories).")"
			unless grep { $_ eq $value } @supported_categories;
		$category = $value;
		
	});

=keyword topics

This function sets the topics for the plugin. Plugins are allowed multiple topics.

=cut

	$stash->add_symbol('&topics', sub {
		while (@_) {
			my $value = shift;
			croak $value." is not a valid topic (Supported: ".join(',',@supported_topics).")"
				unless grep { $_ eq $value } @supported_topics;
			push @topics, $value;
		}
	});

=keyword attribution

This function sets the attribution information for the plugin. The allowed operators are:
	email, twitter, web, github, facebook and cpan.
The allowed formats for each are listed in the %support_types hash above.

=cut

	$stash->add_symbol('&attribution', sub {
		while (@_) {
			my $type = shift;
			my $value = shift;
			croak $type." is not a valid attribution type (Supported: ".join(',',keys %supported_types).")"
				unless grep { $_ eq $type } keys %supported_types;
			push @attributions, [ $type, $value ];
		}
	});

=keyword name

This function sets the name for the plugin.

=cut

	$stash->add_symbol('&name', sub {
		croak 'Only one name allowed.'
			unless scalar @_ == 1;
		my $value = shift;
		$name = $value;
	});

=keyword example_query

This function sets the primary example query for the plugin. 
This is used to show users an example query for the plugin.

=cut

	$stash->add_symbol('&example_query', sub {
		croak 'Only one primary example query allowed.'
			unless scalar @_ == 1;
		my $query = shift;
		$example_query = $query;
	});

=keyword secondary_example_queries

This function sets an array of secondary example queries for the plugin. 
This is used to show users examples of secondary queries for the plugin.

=cut

	$stash->add_symbol('&secondary_example_queries', sub {
		while(@_){
			my $query = shift;
			push @secondary_example_queries, $query;
		}
	});

=keyword icon_url

This function sets the url used to fetch the icon for the plugin.

=cut

	$stash->add_symbol('&icon_url', sub {
		my $value = shift;
		croak $value." is not a valid URL."
			unless $value =~ m/$url_regex/g;
		$icon_url = $value;
	});

=keyword code_urk

This function sets the url which links the plugin's code on github.

=cut

	$stash->add_symbol('&code_url', sub {
		my $value = shift;
		croak $value." is not a valid URL."
			unless $value =~ m/$url_regex/g;
		$code_url = $value;
	});

=keyword get_category

This function returns the plugin's category

=cut

	$stash->add_symbol('&get_category', sub {
		return $category;
	});

=keyword get_topics

This function returns the plugin's topics in an array

=cut

	$stash->add_symbol('&get_topics', sub {
		return \@topics;
	});

=keyword get_meta_information

This function returns the plugin's meta information in a hash

=cut

	$stash->add_symbol('&get_meta_information', sub {
		my %meta_information;
		
		$meta_information{name} = $name;
		$meta_information{example_query} = $example_query;	
		$meta_information{secondary_example_queries} = \@secondary_example_queries;
		$meta_information{icon_url} = $icon_url;
		$meta_information{code_url} = $code_url;

		return \%meta_information;
	});

=keyword get_attributions

This function returns the plugin's attribution information in a hash

=cut

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

	#
	# apply role
	#

	Moo::Role->apply_role_to_package($target,'DDG::HasAttribution');

}

#
# Function taken from URL::RegexMatching 
# - couldn't install due to bad Makefile
#
sub url_match_regex {
    return
      qr{(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))};
}

1;
