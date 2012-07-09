package DDG::Test::Language;
# ABSTRACT: Gives functions for getting test L<DDG::Language> objects.

use strict;
use warnings;
use DDG::Language;
use Package::Stash;
use utf8;

=head1 DESCRIPTION

Installs functions for getting test languages.

B<Warning>: Be aware that you only use this module inside your test files in B<t/>.

=cut

our %languages = (
	'us' => {
		'flagicon' => 'us',
		'flag_url' => 'https://duckduckgo.com/f2/us.png',
		'name_in_local' => 'English of United States',
		'rtl' => 0,
		'locale' => 'en_US',
		'nplurals' => 2,
		'name_in_english' => 'English of United States',
	},
	'de' => {
		'flagicon' => 'de',
		'flag_url' => 'https://duckduckgo.com/f2/de.png',
		'name_in_local' => 'Deutsch von Deutschland',
		'rtl' => 0,
		'locale' => 'de_DE',
		'nplurals' => 2,
		'name_in_english' => 'German of Germany',
	},
	'my' => {
		'flagicon' => 'my',
		'flag_url' => 'https://duckduckgo.com/f2/my.png',
		'name_in_local' => 'Bahasa Malaysia di Malaysia',
		'rtl' => 0,
		'locale' => 'ms_MY',
		'nplurals' => 1,
		'name_in_english' => 'Malay in Malaysia',
	},
);

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;
	my $stash = Package::Stash->new($target);

=keyword test_language

Gives back an example L<DDG::Location> defined by the first parameter.
Possible values are B<us>, B<de> and B<my>.

=cut

	$stash->add_symbol('&test_language', sub {
		my $language_key = shift;
		die "Unknown language_key \"".$language_key."\"" unless defined $languages{$language_key};
		return DDG::Language->new( %{$languages{$language_key}} );
	});

=keyword test_language_by_env

Will give back a L<DDG::Language> like </test_language> but will take the
location definition by the ENV variable B<DDG_TEST_LANGUAGE>. If none is
given then B<us> will be assumed. L<App::DuckPAN> is also using this
function for getting the language for the sample requests, so you can
set another location with prefixing your startup of B<server> or B<query>
with the ENV variable:

  DDG_TEST_LANGUAGE=de duckpan server

=cut

	$stash->add_symbol('&test_language_by_env', sub {
		my $language_key = defined $ENV{DDG_TEST_LANGUAGE} ? $ENV{DDG_TEST_LANGUAGE} : 'us';
		$stash->get_symbol('&test_language')->($language_key);
	});

}

1;
 