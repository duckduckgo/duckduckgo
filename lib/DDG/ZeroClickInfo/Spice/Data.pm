package DDG::ZeroClickInfo::Spice::Data;
# ABSTRACT: Data that gets delivered additional to the spice call into the Javascript of the HTML

use Moo;

has data => (
	is => 'ro',
	required => 1,
);

sub add_data {
	my ( $self, $data ) = @_;
	die "can only handle DDG::ZeroClickInfo::Spice::Data" unless ref $data eq 'DDG::ZeroClickInfo::Spice::Data';
	$self->data->{$_} = $data->data->{$_} for (keys %{$data->data});
}

1;