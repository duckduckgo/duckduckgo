package DDG::Rewrite;
# ABSTRACT: A (mostly spice related) Rewrite definition in our system

use Moo;
use Carp qw( croak );
use URI;

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

=head1 SYNOPSIS

  my $rewrite = DDG::Rewrite->new(
    path => '/js/test/',
    to => 'http://some.api/$1',
  );

  print $rewrite->nginx_conf;

  # location ^~ /js/test/ {
  #   rewrite ^/js/test/(.*) /$1 break;
  #   proxy_pass http://some.api:80/;
  # }

  my $missing_rewrite = DDG::Rewrite->new(
    path => '/js/test/',
    to => 'http://some.api/$1/?key={{ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY}}}',
  );

  if ($missing_rewrite->missing_envs) { ... }

  # is false if $ENV{DDGTEST_DDG_REWRITE_TEST_API_KEY} is not set

=head1 DESCRIPTION

This class is used to contain a definition for a rewrite in our system. So far its specific
designed for the problems we face towards spice redirects, but the definition is used in
the L<App::DuckPAN> test server. In the production system we use those definitions to
generate an L<nginx|http://duckduckgo.com/?q=nginx> config.

=cut

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

has wrap_string_callback => (
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
	my $port = $uri->port;
	my $scheme = $uri->scheme;
	my $uri_path = $self->parsed_to;
	$uri_path =~ s!$scheme://$host:$port!!;
	$uri_path =~ s!$scheme://$host!!;

    # wrap various other things into jsonp
    croak "Cannot use wrap_jsonp_callback and wrap_string callback at the same time!" if $self->wrap_jsonp_callback && $self->wrap_string_callback;
	my $wrap_jsonp_callback = $self->has_callback && $self->wrap_jsonp_callback;
	my $wrap_string_callback = $self->has_callback && $self->wrap_string_callback;

	my $cfg = "location ^~ ".$self->path." {\n";
	$cfg .= "\techo_before_body '".$self->callback."(';\n" if $wrap_jsonp_callback;
	$cfg .= "\techo_before_body '".$self->callback.qq|("';\n| if $wrap_string_callback;
	$cfg .= "\trewrite ^".$self->path.($self->has_from ? $self->from : "(.*)")." ".$uri_path." break;\n";
	$cfg .= "\tproxy_pass ".$scheme."://".$host.":".$port."/;\n";
	$cfg .= "\tproxy_cache_valid ".$self->proxy_cache_valid.";\n" if $self->has_proxy_cache_valid;
	$cfg .= "\tproxy_ssl_session_reuse ".$self->proxy_ssl_session_reuse.";\n" if $self->has_proxy_ssl_session_reuse;
	$cfg .= "\techo_after_body ');';\n" if $wrap_jsonp_callback;
	$cfg .= "\techo_after_body '\");';\n" if $wrap_string_callback;
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

1;
