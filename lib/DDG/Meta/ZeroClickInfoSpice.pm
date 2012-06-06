package DDG::Meta::ZeroClickInfoSpice;
{
  $DDG::Meta::ZeroClickInfoSpice::VERSION = '0.042';
}

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo::Spice;
use DDG::Rewrite;
use Package::Stash;
use URI::Encode qw(uri_encode uri_decode);
use IO::All;

sub zeroclickinfospice_attributes {qw(
	call
	call_type
	caller
	is_cached
	ttl
	from
	to
	wrap_jsonp_callback
	proxy_cache_valid
	proxy_ssl_session_reuse
)}

sub check_zeroclickinfospice_key {
	my $key = shift;
	if (grep { $key eq $_ } zeroclickinfospice_attributes) {
		return $key;
	} else {
		croak $key." is not supported on DDG::ZeroClickInfo::Spice";
	}
}

my %applied;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	return if exists $applied{$target};
	$applied{$target} = undef;

	my @parts = split('::',$target);
	my $callback = join('_',map { s/([a-z])([A-Z])/$1_$2/g; lc; } @parts);
	shift @parts;
	my $path = '/js/'.join('/',map { s/([a-z])([A-Z])/$1_$2/g; lc; } @parts).'/';
	shift @parts;
	my $answer_type = lc(join(' ',@parts));

	my %zcispice_params = (
		caller => $target,
		call_type => 'include',
		call => $path,
		wrap_jsonp_callback => 0,
	);

	my $stash = Package::Stash->new($target);
	$stash->add_symbol('&call',sub {
		my %params = %zcispice_params;
		delete $params{'from'};
		delete $params{'to'};
		delete $params{'wrap_jsonp_callback'};
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
		delete $params{'from'};
		delete $params{'to'};
		for (@_) {
			if (ref $_ eq 'HASH') {
				for my $k (keys %{$_}) {
					$params{$k} = $_->{$k};
				};
			} elsif (ref $_ eq 'DDG::ZeroClickInfo::Spice') {
				return $_;
			} elsif (!defined $_) {
				# do nothing
			} else {
				push @call, $_;
			}
		}
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
	### SHOULD GET DEPRECATED vvvv ###
	$stash->add_symbol('&spice_from',sub { $zcispice_params{'from'} });
	$stash->add_symbol('&spice_to',sub { $zcispice_params{'to'} });
	$stash->add_symbol('&spice_call_type',sub { $zcispice_params{'call_type'} });
	###                       ^^^^ ###
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
				$rewrite = DDG::Rewrite->new(
					to => $zcispice_params{'to'},
					defined $zcispice_params{'from'} ? ( from => $zcispice_params{'from'}) : (),
					defined $zcispice_params{'proxy_cache_valid'} ? ( proxy_cache_valid => $zcispice_params{'proxy_cache_valid'} ) : (),
					defined $zcispice_params{'proxy_ssl_session_reuse'} ? ( proxy_ssl_session_reuse => $zcispice_params{'proxy_ssl_session_reuse'} ) : (),
					callback => $callback,
					path => $path,
					wrap_jsonp_callback => $zcispice_params{'wrap_jsonp_callback'},
				);
			} else {
				$rewrite = "";
			}
		}
		return $rewrite;
	});
	$stash->add_symbol('&get_nginx_conf',sub {
		my $nginx_conf_func = $stash->get_symbol('&nginx_conf');
		return $nginx_conf_func->(@_) if $nginx_conf_func;
		return "" unless $target->has_rewrite;
		return $target->rewrite->nginx_conf;
	});
}

1;
