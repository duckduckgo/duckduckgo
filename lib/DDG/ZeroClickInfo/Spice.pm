package DDG::ZeroClickInfo::Spice;

use Moo;

has call => (
	is => 'ro',
);

has call_path => (
	is => 'ro',
	lazy_build => 1,
	builder => '_build_call_path',
);

sub _build_call_path {
	my ( $self ) = @_;
	my @parts = split('::',$self->caller);
	shift @parts;
	my $path = join('/',map { s/([a-z])([A-Z])/$1_$2/; lc; } @parts);
	return $self->call_path_root.$path.'/';
}

has call_path_root => (
	is => 'ro',
	lazy_build => 1,
	builder => '_build_call_path_root',
);

sub _build_call_path_root { '/' }

has caller => (
	is => 'ro',
	required => 1,
);

has is_cached => (
	is => 'ro',
	default => sub { 1 },
);

has spice_js_file => (
	is => 'ro',
	lazy_build => 1,
	builder => '_build_spice_js_file',
);

sub _build_spice_js_file {
	my ( $self ) = @_;
	my $filename = $self->caller->share->file('spice.js')->absolute;
	return -f $filename ? $filename : undef;
}

1;