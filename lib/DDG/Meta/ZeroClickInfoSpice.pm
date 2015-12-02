package DDG::Meta::ZeroClickInfoSpice;
# ABSTRACT: Functions for generating a L<DDG::ZeroClickInfo::Spice> factory

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo::Spice;
use DDG::ZeroClickInfo::Spice::Data;
use DDG::Rewrite;
use Package::Stash;
use URI::Encode qw(uri_encode uri_decode);
use IO::All;

sub zeroclickinfospice_attributes {qw(
	call
	call_type
	caller
	from
	proxy_cache_valid
	proxy_ssl_session_reuse
	to
	wrap_jsonp_callback
	wrap_string_callback
	accept_header
	is_cached
	is_unsafe
	ttl
	error_fallback
	alt_to
)}

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	return if exists $applied{$target};
	$applied{$target} = undef;

	my ($callback, $path, $answer_type) = @{params_from_target($target)};

	my %zcispice_params = (
		caller => $target,
		call_type => 'include',
		call => $path,
		wrap_jsonp_callback => 0,
		wrap_string_callback => 0,
		accept_header => 0,
	);

	my $stash = Package::Stash->new($target);

	$stash->add_symbol('&call',sub {
		my %params = %zcispice_params;
		delete $params{'from'};
		delete $params{'to'};
		delete $params{'wrap_jsonp_callback'};
		delete $params{'wrap_string_callback'};
		delete $params{'accept_header'};
		delete $params{'proxy_cache_valid'};
		delete $params{'proxy_ssl_session_reuse'};
		return DDG::ZeroClickInfo::Spice->new(
			%params,
		);
	});

	$stash->add_symbol('&spice_new',sub {
		shift;
		my @call;
		my %params = %zcispice_params;
		my $data;
		delete $params{'from'};
		delete $params{'to'};
		for (@_) {
			if (ref $_ eq 'HASH') {
				for my $k (keys %{$_}) {
					$params{$k} = $_->{$k};
				};
			} elsif (ref $_ eq 'DDG::ZeroClickInfo::Spice::Data') {
				if ($data) {
					$data->add_data($_);
				} else {
					$data = $_;
				}
			} elsif (ref $_ eq 'DDG::ZeroClickInfo::Spice') {
				return $_;
			} elsif (!defined $_) {
				# do nothing
			} else {
				push @call, $_;
			}
		}
		$params{'call_data'} = $data->data if $data;
		if (@call) {
			if ($params{'call_type'} eq 'include') {
				$params{'call'} = $target->path.join('/',map { uri_encode($_,1) } @call);
			} elsif (scalar @call == 1) {
				$params{'call'} = $call[0];
			} else {
				croak "DDG::ZeroClickInfo::Spice can't handle more then one value in return list on non include call_type";
			}
		}
		DDG::ZeroClickInfo::Spice->new(%params)
	});

	$stash->add_symbol('&spice',sub {
		if (ref $_[0] eq 'HASH') {
			for (keys %{$_[0]}) {
				$zcispice_params{check_zeroclickinfospice_key($_)} = $_[0]->{$_};
			}
		} else {
			while (@_) {
				my $key = shift;
				my $value = shift;
				$zcispice_params{check_zeroclickinfospice_key($key)} = $value;
			}
		}
	});

	$stash->add_symbol('&callback',sub { $callback });

	$stash->add_symbol('&path',sub { $path });

	my $spice_js;

	$stash->add_symbol('&data',sub {
		unshift @_, %{$_[0]} if ref $_[0] eq 'HASH';
		my ( %data ) = @_;
		return DDG::ZeroClickInfo::Spice::Data->new( data => \%data );
	});

	$stash->add_symbol('&spice_js',sub {
		return $spice_js if defined $spice_js;
		my ( $self ) = @_;
		$spice_js = "";
		if ($target->can('module_share_dir') && (my $spice_js_file = $target->can('share')->('spice.js'))) {
			$spice_js .= io($spice_js_file)->slurp;
			$spice_js .= "\n";
		}
		if ($target->spice_call_type eq 'self') {
			$spice_js .= $target->callback."();";
		}
		return $spice_js;
	});

	my $rewrite;
	$stash->add_symbol('&has_rewrite',sub {
		defined $zcispice_params{'to'};
	});

	$stash->add_symbol('&rewrite',sub {
		unless (defined $rewrite) {
			if ($target->has_rewrite) {
				$rewrite = create_rewrite($callback, $path, \%zcispice_params);
			} 
			else {
				$rewrite = '';
			}
		}
		return $rewrite;
	});

	# make these accessbile, e.g. for duckpan
	$stash->add_symbol('&alt_rewrites', sub {
		my %rewrites;
		# check if we have alternate end points to add
		if(my $alt_to = $zcispice_params{alt_to}){
			my ($base_target) = $target =~ /^(.+::)\w+$/;
			while(my ($to, $params) = each %$alt_to){
				check_zeroclickinfospice_key($_) for keys %$params;
				my $target = "$base_target$to";
				my ($callback, $path) = @{params_from_target($target)};
				$rewrites{$to} = create_rewrite($callback, $path, $params);
			}
		}

		return \%rewrites;
	});

	$stash->add_symbol('&get_nginx_conf',sub {
		my $nginx_conf_func = $stash->get_symbol('&nginx_conf');
		return $nginx_conf_func->(@_) if $nginx_conf_func;
		return '' unless $target->has_rewrite;
		my $conf = $target->rewrite->nginx_conf;

		# check if we have alternate end points to add
		for my $r (values %{$target->alt_rewrites}){
			$conf .= $r->nginx_conf;
		}

		return $conf;
	});

	### SHOULD GET DEPRECATED vvvv ###
	$stash->add_symbol('&spice_from',sub { $zcispice_params{'from'} });
	$stash->add_symbol('&spice_to',sub { $zcispice_params{'to'} });
	$stash->add_symbol('&spice_call_type',sub { $zcispice_params{'call_type'} });
	###                       ^^^^ ###

}

sub check_zeroclickinfospice_key {
	my $key = shift;
	if (grep { $key eq $_ } zeroclickinfospice_attributes) {
		return $key;
	} else {
		croak $key." is not supported on DDG::ZeroClickInfo::Spice";
	}
}

sub params_from_target {
	my $target = shift;

	my @parts = split('::',$target);
	my $callback = join('_',map { s/([a-z])([A-Z])/$1_$2/g; lc; } @parts);
	shift @parts;
	my $path = '/js/'.join('/',map { s/([a-z])([A-Z])/$1_$2/g; lc; } @parts).'/';
	shift @parts;
	my $answer_type = lc(join(' ',@parts));

	return [$callback, $path, $answer_type];
}

sub create_rewrite {
	my ($callback, $path, $params) = @_;

	return DDG::Rewrite->new(
		to => $params->{to},
		defined $params->{from} ? ( from => $params->{from}) : (),
		defined $params->{proxy_cache_valid} ? ( proxy_cache_valid => $params->{proxy_cache_valid} ) : (),
		defined $params->{proxy_ssl_session_reuse} ? ( proxy_ssl_session_reuse => $params->{proxy_ssl_session_reuse} ) : (),
		callback => $callback,
		path => $path,
		wrap_jsonp_callback => $params->{wrap_jsonp_callback},
		wrap_string_callback => $params->{wrap_string_callback},
		accept_header => $params->{accept_header},
		error_fallback => $params->{error_fallback}
	);
}

1;
