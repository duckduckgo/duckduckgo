package DDG::Location;
# ABSTRACT: A location, can be empty (given by Geo::IP::Record)

use Moo;

my @geo_ip_record_attrs = qw( country_code country_code3 country_name region
	region_name city postal_code latitude longitude time_zone area_code
	continent_code metro_code );

my @geo_ip_record_s = (@geo_ip_record_attrs, 'loc_str');

sub new_from_geo_ip_record {
	my ( $class, $geo_ip_record ) = @_;

	if ($geo_ip_record) {
		my %args;
		for (@geo_ip_record_attrs) {
			$args{$_} = $geo_ip_record->$_ if defined $geo_ip_record->$_;
		}

        # add short location summary string: postal_code if it exists, otherwise 'city, country' or 'region, country'
        my $city = $geo_ip_record->city || $geo_ip_record->region_name;

        if ($city) {
            $city .= ', ' . $geo_ip_record->country_name if $geo_ip_record->country_name;
        }

        $args{loc_str} = $geo_ip_record->postal_code || $city || '';

		return $class->new(
			geo_ip_record => $geo_ip_record,
			%args,
		);
	} else {
		return $class->new;
	}
}

has $_ => (
	is => 'ro',
	default => sub { '' }
) for (@geo_ip_record_s);

has geo_ip_record => (
	is => 'ro',
	predicate => 'has_geo_ip_record',
);

use overload '""' => sub {
	my $self = shift;
	return $self->country_code;
}, fallback => 1;

1;
