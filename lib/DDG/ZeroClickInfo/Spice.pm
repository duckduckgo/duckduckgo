package DDG::ZeroClickInfo::Spice;

use Moo;
use URI;

has call => (
	is => 'ro',
	predicate => 'has_call',
);

has caller => (
	is => 'ro',
	required => 1,
);

has from => (
	is => 'ro',
	predicate => 'has_from',
);

has to => (
	is => 'ro',
	predicate => 'has_to',
);

has is_cached => (
	is => 'ro',
	default => sub { 1 },
);

has spice_js_file => (
	is => 'ro',
	lazy => 1,
	builder => '_build_spice_js_file',
);

sub _build_spice_js_file {
	my ( $self ) = @_;
	my $filename = $self->caller->share->file('spice.js')->absolute;
	return -f $filename ? $filename : undef;
}

has path => (
	is => 'ro',
	lazy => 1,
	builder => '_build_path',
);

sub _build_path {
	my ( $self ) = @_;
	my @parts = split('::',$self->caller);
	shift @parts;
	return '/js/'.join('/',map { s/([a-z])([A-Z])/$1_$2/; lc; } @parts).'/';
}

has nginx_conf => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nginx_conf',
);

sub _build_nginx_conf {
	my ( $self ) = @_;
	my $uri = URI->new($self->to);
	my $host = $uri->host;
	my $scheme = $uri->scheme;
	my $uri_path = $self->to;
	$uri_path =~ s!$scheme://$host!!;
	my $self_path = $self->path;
	my $from = $self->has_from ? $self->from : "(.*)";
	return <<"__END_OF_CONF__";

location ^~ $self_path {
  rewrite ^$self_path$from $uri_path break;
  proxy_pass $scheme://$host/;
}

__END_OF_CONF__
}

1;