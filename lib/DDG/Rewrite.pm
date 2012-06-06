package DDG::Rewrite;
{
  $DDG::Rewrite::VERSION = '0.042';
}

use Moo;
use Carp qw( croak );
use URI;

has path => (
	is => 'ro',
	required => 1,
);

has to => (
	is => 'ro',
	required => 1,
);

has from => (
	is => 'ro',
	predicate => 'has_from',
);

has callback => (
	is => 'ro',
	predicate => 'has_callback',
);

has wrap_jsonp_callback => (
	is => 'ro',
	default => sub { 0 },
);

has proxy_cache_valid => (
	is => 'ro',
	predicate => 'has_proxy_cache_valid',
);

has proxy_ssl_session_reuse => (
	is => 'ro',
	predicate => 'has_proxy_ssl_session_reuse',
);

has nginx_conf => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nginx_conf',
);

sub _build_nginx_conf {
	my ( $self ) = @_;
	my $uri = URI->new($self->parsed_to);
	my $host = $uri->host;
	my $scheme = $uri->scheme;
	my $uri_path = $self->parsed_to;
	$uri_path =~ s!$scheme://$host!!;
	my $wrap_jsonp_callback = $self->has_callback && $self->wrap_jsonp_callback;
	my $cfg = "location ^~ ".$self->path." {\n";
	$cfg .= "\techo_before_body '".$self->callback."(';\n" if $wrap_jsonp_callback;
	$cfg .= "\trewrite ^".$self->path.($self->has_from ? $self->from : "(.*)")." ".$uri_path." break;\n";
	$cfg .= "\tproxy_pass ".$scheme."://".$host."/;\n";
	$cfg .= "\tproxy_cache_valid ".$self->proxy_cache_valid.";\n" if $self->has_proxy_cache_valid;
	$cfg .= "\tproxy_ssl_session_reuse ".$self->proxy_ssl_session_reuse.";\n" if $self->has_proxy_ssl_session_reuse;
	$cfg .= "\techo_after_body ');';\n" if $wrap_jsonp_callback;
	$cfg .= "}\n";
	return $cfg;
}

has _missing_envs => (
	is => 'rw',
	predicate => 'has_missing_envs',
);
sub missing_envs { shift->_missing_envs }

has _parsed_to => (
	is => 'rw',
);
sub parsed_to { shift->_parsed_to }

sub BUILD {
	my ( $self ) = @_;
	my $to = $self->to;
	my $callback = $self->has_callback ? $self->callback : "";
	croak "Missing callback attribute for {{callback}} in to" if ($to =~ s/{{callback}}/$callback/g && !$self->has_callback);
	my @missing_envs;
	for ($to =~ m/{{ENV{(\w+)}}}/g) {
		if (defined $ENV{$1}) {
			my $val = $ENV{$1};
			$to =~ s/{{ENV{$1}}}/$val/g;
		} else {
			push @missing_envs, $1;
			$to =~ s/{{ENV{$1}}}//g;
		}
	}
	$self->_missing_envs(\@missing_envs) if @missing_envs;
	$self->_parsed_to($to);
}

1;