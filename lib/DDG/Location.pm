package DDG::Location;
# ABSTRACT: A specific location (given by Geo::IP::Record)

use Moo;

my @geo_ip_record_attrs = qw( country_code country_code3 country_name region
	region_name city postal_code latitude longitude time_zone area_code
	continent_code metro_code );

sub new_from_geo_ip_record {
	my ( $class, $geo_ip_record ) = @_;
	my %vars = map { $_ => $geo_ip_record->$_ } @geo_ip_record_attrs;
	return $class->new(
		geo_ip_record => $geo_ip_record,
		%vars,
	);
}

has $_ => (
	is => 'ro',
	predicate => 'has_'.$_,
) for (@geo_ip_record_attrs);

has geo_ip_record => (
	is => 'ro',
	predicate => 'has_geo_ip_record',
);

1;