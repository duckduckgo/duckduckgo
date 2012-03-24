package DDG::Meta::ZeroClickInfo;

use strict;
use warnings;
use Carp;
use DDG::ZeroClickInfo;

sub zeroclickinfo_attributes {qw(
	abstract
	abstract_text
	abstract_source
	abstract_url
	image
	heading
	answer
	answer_type
	definition
	definition_source
	definition_url
	type
	is_cached
)}

sub check_zeroclickinfo_key {
	my $key = shift;
	if (grep { $key eq $_ } zeroclickinfo_attributes) {
		return $key;
	} else {
		croak $key." is not supported on DDG::ZeroClickInfo";
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
		my %zci_params = (
			answer_type => $answer_type,
		);
		no strict "refs";

		*{"${target}::zci_new"} = sub {
			shift;
			DDG::ZeroClickInfo->new( %zci_params, ref $_[0] eq 'HASH' ? %{$_[0]} : @_ );
		};
		*{"${target}::zci"} = sub {
			if (ref $_[0] eq 'HASH') {
				for (keys %{$_[0]}) {
					$zci_params{check_zeroclickinfo_key($_)} = $_[0]->{$_};
				}
			} else {
				while (@_) {
					my $key = shift;
					my $value = shift;
					$zci_params{check_zeroclickinfo_key($key)} = $value;
				}
			}
		};
	}

}

1;
