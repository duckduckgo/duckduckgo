package DDG::ZeroClickInfo::Spice;

use Moo;
use URI;
use URI::Encode qw(uri_encode uri_decode);

has call => (
	is => 'ro',
	predicate => 'has_call',
);

has caller => (
	is => 'ro',
	required => 1,
);

has is_cached => (
	is => 'ro',
	default => sub { 1 },
);

has call_path => (
	is => 'ro',
	lazy => 1,
	builder => '_build_call_path',
);

sub _build_call_path {
	my ( $self ) = @_;
	return $self->caller->path.join('/',map { uri_encode($_,1) } @{$self->call});
}

1;