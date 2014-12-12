package DDG::CountryCodes;

# ABSTRACT: Country codes and names
# see pod below

use strict;
use warnings;

use Moo;
use namespace::autoclean;
use Moose::Exporter;
use Locale::Country ();

# pass throughs
sub country2code { shift; Locale::Country::country2code(@_); }
sub code2country { shift; Locale::Country::code2country(@_); }

Moose::Exporter->setup_import_methods(
  as_is => [ \&Locale::Country::LOCALE_CODE_ALPHA_2,
	     \&Locale::Country::LOCALE_CODE_ALPHA_3,
	   ]
 );

sub BUILD {
  my ( $self ) = @_;

  # ghetto singleton ahoy!
  return if $::ddg_countrycodes_defined;

  # These are the only 2 countries which officially have 'The' in their name
  # Source: http://www.bbc.co.uk/news/magazine-18233844
  Locale::Country::rename_country('gm' => 'The Gambia');
  Locale::Country::rename_country('bs' => 'The Bahamas');

  Locale::Country::add_country_alias('Antigua and Barbuda'  		=> 'Antigua');
  Locale::Country::add_country_alias('Antigua and Barbuda'  		=> 'Barbuda');
  Locale::Country::add_country_alias("Lao People's Democratic Republic" => "Laos");
  Locale::Country::add_country_alias('Russian Federation'   		=> 'Russia');
  Locale::Country::add_country_alias('Trinidad and Tobago'  		=> 'Tobago');
  Locale::Country::add_country_alias('Trinidad and Tobago'  		=> 'Trinidad');
  Locale::Country::add_country_alias('Vatican City'         		=> 'Vatican');
  Locale::Country::add_country_alias('Virgin Islands, U.S.' 		=> 'US Virgin Islands');

  # Source: http://www.bbc.co.uk/news/magazine-18233844
  Locale::Country::add_country_alias('United States' => 'America');

  # Easter eggs
  Locale::Country::add_country_alias('Russian Federation' => 'Kremlin');
  Locale::Country::add_country_alias('United States' 	  => 'murica');
  Locale::Country::add_country_alias('Canada' 		  => 'Canadia');
  Locale::Country::add_country_alias('Australia' 	  => 'down under');

  Locale::Country::rename_country('ae' => 'the United Arab Emirates');
  Locale::Country::rename_country('bs' => 'The Bahamas');
  Locale::Country::rename_country('do' => 'the Dominican Republic');
  Locale::Country::rename_country('gb' => 'the United Kingdom');
  Locale::Country::rename_country('gm' => 'The Gambia');
  Locale::Country::rename_country('kp' => "the Democratic People's Republic of Korea"); # North Korea
  Locale::Country::rename_country('kr' => "the Republic of Korea"); # South Korea
  Locale::Country::rename_country('ky' => 'the Cayman Islands');
  Locale::Country::rename_country('mp' => 'the Northern Mariana Islands');
  Locale::Country::rename_country('nl' => 'the Netherlands');
  Locale::Country::rename_country('ph' => 'the Philippines');
  Locale::Country::rename_country('ru' => 'the Russian Federation');
  Locale::Country::rename_country('tw' => 'Taiwan');
  Locale::Country::rename_country('us' => 'the United States');
  Locale::Country::rename_country('va' => 'the Holy See (Vatican City State)');
  Locale::Country::rename_country('vg' => 'the British Virgin Islands');
  Locale::Country::rename_country('vi' => 'the US Virgin Islands');

  $::ddg_countrycodes_defined ++;
}

__PACKAGE__->meta->make_immutable;

1;

package main;
my $ddg_countrycodes_defined = 0;
1;

__END__

=pod

=head1 NAME

DDG::Country - dumb wrapper for Locale::Country to centralize codes and names

=head1 SYNOPSIS

  use DDG::CountryCodes;
  my $cc = new DDG::CountryCodes();
  ...
  $code = $cc->country2code("Japan");
  $name = $cc->code2country("uk");

=head1 DESCRIPTION

This class factors out some spice and goodie usages of Locale::Country
where there was some organic copying. DDG-local aliases and renames are
centralized here.

Locale::Country is presented as a functional style library, but some of its
calls modify its state, so it's probably cleaner to use it wrapped as an
object for encapsulation.

=head1 TODO

* Surface more of Locale::Country if anybody ever needs it. However, if
new aliases or renames are needed by IA's, they should be done here instead.

=head1 VERSION

version 0.1

=head1 AUTHOR

Mitchell Perilstein <mitchell.perilstein@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by DuckDuckGo, Inc. L<https://duckduckgo.com/>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
