package DDG::ZeroClickInfo::Spice::Data;
# ABSTRACT: Data that gets delivered additional to the spice call into the Javascript of the HTML

use Moo;

=head1 SYNOPSIS

Inside your spice handler

  return $path_part_one, $path_part_two, data(
    key => "value",
    more_key => "more value",
    most_key => "most value - buy now!",
  );

=attr data

Needs a hashref of the data you want to access inside the javascript.

=cut

has data => (
	is => 'ro',
	required => 1,
);

=method add_data

Integrates the given B<DDG::ZeroClickInfo::Spice::Data> into data object. The
newer one always overrides variables already set.

=cut

sub add_data {
	my ( $self, $data ) = @_;
	die "can only handle DDG::ZeroClickInfo::Spice::Data" unless ref $data eq 'DDG::ZeroClickInfo::Spice::Data';
	$self->data->{$_} = $data->data->{$_} for (keys %{$data->data});
}

1;