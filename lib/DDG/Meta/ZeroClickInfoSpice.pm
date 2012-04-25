package DDG::Meta::ZeroClickInfoSpice;

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo::Spice;
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
	my $callback = join('_',map { s/([a-z])([A-Z])/$1_$2/; lc; } @parts);
	shift @parts;
	my $path = '/js/'.join('/',map { s/([a-z])([A-Z])/$1_$2/; lc; } @parts).'/';
	shift @parts;
	my $answer_type = lc(join(' ',@parts));

	my %zcispice_params = (
		caller => $target,
		call_type => 'include',
		call => $path,
	);

	my $stash = Package::Stash->new($target);
	$stash->add_symbol('&call',sub {
		my %params = %zcispice_params;
		delete $params{'from'};
		delete $params{'to'};
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
	$stash->add_symbol('&spice_from',sub { $zcispice_params{'from'} });
	$stash->add_symbol('&spice_to',sub { $zcispice_params{'to'} });
	$stash->add_symbol('&spice_call_type',sub { $zcispice_params{'call_type'} });
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
	my $nginx_conf;
	$stash->add_symbol('&nginx_conf',sub {
		return $nginx_conf if defined $nginx_conf;
		my ( $self ) = @_;
		return "" unless defined $zcispice_params{'to'};
		my $to = $zcispice_params{'to'};
		$to =~ s/{{callback}}/$callback/g;
		my $uri = URI->new($to);
		my $host = $uri->host;
		my $scheme = $uri->scheme;
		my $uri_path = $to;
		$uri_path =~ s!$scheme://$host!!;
		my $from = defined $zcispice_params{'from'} ? $zcispice_params{'from'} : "(.*)";
		$nginx_conf = <<"__END_OF_CONF__";

location ^~ $path {
  rewrite ^$path$from $uri_path break;
  proxy_pass $scheme://$host/;
}

__END_OF_CONF__
		return $nginx_conf;
	});

}

1;
