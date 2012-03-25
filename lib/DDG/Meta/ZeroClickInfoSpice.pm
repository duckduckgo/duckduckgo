package DDG::Meta::ZeroClickInfoSpice;

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo::Spice;

sub zeroclickinfospice_attributes {qw(
	call
	caller
	is_cached
	ttl
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
	
	{
		my %zcispice_params = (
			caller => $target,
		);
		no strict "refs";

		*{"${target}::spice_new"} = sub {
			shift;
			DDG::ZeroClickInfo::Spice->new(%zcispice_params, ref $_[0] eq 'HASH' ? %{$_[0]} : @_)
		};
		*{"${target}::spice"} = sub {
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
		};
	}

}

1;
