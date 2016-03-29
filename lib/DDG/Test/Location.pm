package DDG::Test::Location;
# ABSTRACT: Gives functions for getting test L<DDG::Location> objects.

use strict;
use warnings;
use DDG::Location;
use Package::Stash;
use utf8;

=head1 DESCRIPTION

Installs functions for getting test locations.

B<Warning>: Be aware that you only use this module inside your test files in B<t/>.

=cut

our %locations = (
	'us' => {
		country_code => 'US',
		country_code3 => 'USA',
		country_name => 'United States',
		region => 'PA',
		region_name => 'Pennsylvania',
		city => 'Phoenixville',
		postal_code => '19460',
		latitude => '40.1246',
		longitude => '-75.5385',
		time_zone => 'America/New_York',
		area_code => '610',
		continent_code => 'NA',
		metro_code => '504',
	loc_str => '19460'
	},
	'de' => {
		country_code => 'DE',
		country_code3 => 'DEU',
		country_name => 'Germany',
		region => '07',
		region_name => 'Nordrhein-Westfalen',
		city => 'Mönchengladbach',
		latitude => '51.2000',
		longitude => '6.4333',
		time_zone => 'Europe/Berlin',
		area_code => 0,
		continent_code => 'EU',
		metro_code => 0,
	loc_str => 'Mönchengladbach, Germany',
	},
	'my' => {
		country_code => 'MY',
		country_code3 => 'MYS',
		country_name => 'Malaysia',
		region => '14',
		region_name => 'Kuala Lumpur',
		city => 'Kuala Lumpur',
		latitude => '3.1667',
		longitude => '101.7000',
		area_code => 0,
		continent_code => 'AS',
		metro_code => 0,
	loc_str => 'Kuala Lumpur, Malaysia',
	},
	'in' => {
		country_code => 'IN',
		country_code3 => 'IND',
		country_name => 'India',
		region => '07',
		region_name => 'Delhi',
		city => 'New Delhi',
		latitude => '28.6000',
		longitude => '77.2000',
		time_zone => 'Asia/Calcutta',
		area_code => 0,
		continent_code => 'AS',
		metro_code => 0,
	loc_str => 'New Delhi, India',
	},
	'au' => {
		country_code => 'AU',
		country_code3 => 'AUS',
		country_name => 'Australia',
		region => 'SA',
		region_name => 'South Australia',
		city => 'Adelaide',
		latitude => '-34.5544',
		longitude => '138.3636',
		time_zone => 'Australia/Adelaide',
		area_code => 0,
		continent_code => 'AU',
		metro_code => 0,
	},
);

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;
	my $stash = Package::Stash->new($target);

=keyword test_location

Gives back an example L<DDG::Location> defined by the first parameter.
Possible values are B<us>, B<de>, B<in> and B<my>.

=cut

	$stash->add_symbol('&test_location', sub {
		my $location_key = shift;
		die "Unknown location_key \"".$location_key."\"" unless defined $locations{$location_key};
		return DDG::Location->new( %{$locations{$location_key}} );
	});

=keyword test_location_by_env

Will give back a L<DDG::Location> like </test_location> but will take the
location definition by the ENV variable B<DDG_TEST_LOCATION>. If none is
given then B<us> will be assumed. L<App::DuckPAN> is also using this
function for getting the location for the sample requests, so you can
set another location with prefixing your startup of B<server> or B<query>
with the ENV variable:

  DDG_TEST_LOCATION=de duckpan server

=cut

	$stash->add_symbol('&test_location_by_env', sub {
		my $location_key = defined $ENV{DDG_TEST_LOCATION} ? $ENV{DDG_TEST_LOCATION} : 'us';
		$stash->get_symbol('&test_location')->($location_key);
	});

}

1;
 
