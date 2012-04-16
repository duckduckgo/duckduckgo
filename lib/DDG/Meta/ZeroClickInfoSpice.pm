package DDG::Meta::ZeroClickInfoSpice;

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo::Spice;
use Package::Stash;

sub zeroclickinfospice_attributes {qw(
	call
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
	);

	my $stash = Package::Stash->new($target);
	$stash->add_symbol('&call_self',sub { undef });
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
		$params{'call'} = [@call] if @call;
		DDG::ZeroClickInfo::Spice->new(%params)
	});
	$stash->add_symbol('&spice_from',sub { $zcispice_params{'from'} });
	$stash->add_symbol('&spice_to',sub { $zcispice_params{'to'} });
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
