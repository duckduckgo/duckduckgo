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
	# Make sure we replace "{{dollar}}"" with "{dollar}".
	$to =~ s/{{dollar}}/\$\{dollar\}/g;
	my @missing_envs;
	for ($to =~ m/{{ENV{(\w+)}}}/g) {
		if (defined $ENV{$_}) {
			my $val = $ENV{$_};
			$to =~ s/{{ENV{$_}}}/$val/g;
		} else {
			push @missing_envs, $_;
			$to =~ s/{{ENV{$_}}}//g;
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

has accept_header => (
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

has proxy_x_forwarded_for => (
        is => 'ro',
        default => sub { 'X-Forwarded-For $proxy_add_x_forwarded_for' }
);

has nginx_conf => (
	is => 'ro',
	lazy => 1,
	builder => '_build_nginx_conf',
);

has uses_browser_location => (
    is => 'rw',
    default => sub { 0 },
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
	my $is_duckduckgo = $host =~ /(?:127\.0\.0\.1|duckduckgo\.com)/;

	# wrap various other things into jsonp
	croak "Cannot use wrap_jsonp_callback and wrap_string callback at the same time!" if $self->wrap_jsonp_callback && $self->wrap_string_callback;
	my $wrap_jsonp_callback = $self->has_callback && $self->wrap_jsonp_callback;
	my $wrap_string_callback = $self->has_callback && $self->wrap_string_callback;
	my $uses_echo_module = $wrap_jsonp_callback || $wrap_string_callback;

	my $cfg = "location ^~ ".$self->path." {\n";
	$cfg .= "\tproxy_set_header Accept '".$self->accept_header."';\n" if $self->accept_header;
	
	if($uses_echo_module) {
		# we need to make sure we have plain text coming back until we have a way
		# to unilaterally gunzip responses from the upstream since the echo module
		# will intersperse plaintext with gzip which results in encoding errors.
		# https://github.com/agentzh/echo-nginx-module/issues/30
		$cfg .= "\tproxy_set_header Accept-Encoding '';\n";

		# This is a workaround that deals with endpoints that don't support callback functions.
		# So endpoints that don't support callback functions return a content-type of 'application/json'
		# because what they're returning is not meant to be executed in the first place.
		# Setting content-type to application/javascript for those endpoints solves blocking due to 
		# mime type mismatches.
		$cfg .= "\tmore_set_headers 'Content-Type: application/javascript; charset=utf-8';\n";
	}

	if($uses_echo_module || $self->accept_header || $is_duckduckgo) {
		$cfg .= "\tinclude /usr/local/nginx/conf/nginx_inc_proxy_headers.conf;\n";
	}

	$cfg .= "\techo_before_body '".$self->callback."(';\n" if $wrap_jsonp_callback;
	$cfg .= "\techo_before_body '".$self->callback.qq|("';\n| if $wrap_string_callback;

	my $upstream;
	if(my ($spice_name) = $self->path =~ m{^/js/spice/(.+)/$}){
		$spice_name =~ s|/|_|og;
		$upstream = '$'.$spice_name.'_upstream';
		$cfg .= "\tset $upstream $scheme://$host:$port;\n";
	} else {
		warn "Error: Problem finding spice name in ".$self->path; return
	}

        if ($self->uses_browser_location) {
            $cfg .= "\t".'if ($arg_latlon) {'."\n";
            $cfg .= "\t\t".'set $query_latlon $arg_latlon;'."\n";
            $cfg .= "\t\t".'rewrite ^/js/spice/maps/places/(.*) /local.js?q=$1&latlon=$query_latlon&cb=ddg_spice_maps_places break;'."\n";
            $cfg .= "\t}\n";
        }

	$cfg .= "\trewrite ^".$self->path.($self->has_from ? $self->from : "(.*)")." ".$uri_path." break;\n";
	$cfg .= "\tproxy_pass $upstream;\n";
	$cfg .= "\tproxy_set_header ".$self->proxy_x_forwarded_for.";\n" if $is_duckduckgo;

	if($self->has_proxy_cache_valid) {
		# This tells Nginx how long the response should be kept.
		$cfg .= "\tproxy_cache_valid " . $self->proxy_cache_valid . ";\n";
		# Some response headers from the endpoint can affect `proxy_cache_valid` so we ignore them.
		# http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_ignore_headers
		$cfg .= "\tproxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;\n";
	}

	$cfg .= "\tproxy_ssl_session_reuse ".$self->proxy_ssl_session_reuse.";\n" if $self->has_proxy_ssl_session_reuse;
	$cfg .= "\techo_after_body ');';\n" if $wrap_jsonp_callback;
	$cfg .= "\techo_after_body '\");';\n" if $wrap_string_callback;

	# proxy_intercept_errors is used to handle endpoints that don't return 200 OK
	# When we get errors from the endpoint, instead of replying a blank page, it should reply the function instead with no parameters,
	# e.g., ddg_spice_dictionary_definition();. The benefit of doing that is that we know for sure that the Spice failed, and we can do
	# something about it (we know that the Spice failed because it should return Spice.failed('...') when the parameters are not valid).
	if($self->callback) {
		$cfg .= "\tproxy_intercept_errors on;\n";
		$cfg .= "\terror_page 301 302 303 403 404 500 502 503 504 =200 /js/failed/".$self->callback.";\n";
	}

	$cfg .= "\texpires 1s;\n";
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
