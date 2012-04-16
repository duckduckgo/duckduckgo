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
	shift @parts;
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

}

1;
