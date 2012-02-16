package DDG::Meta::Goodie;

use strict;
use warnings;
use Carp;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	# {
		# my %words;
		# no strict "refs";

		# *{"${target}::all_words_by_type"} = sub { \%words };
		# *{"${target}::has_words"} = sub { %words ? 1 : 0 };
		# *{"${target}::words"} = sub {
			# my @args;
			# if (ref $_[0] eq 'CODE') {
				# @args = { $_[0]->() };
			# } else {
				# @args = @_;
			# }
			# if (ref $args[0] eq 'HASH') {
				# my %types = %{$args[0]};
				# for my $type (keys %types) {
					# my $value = $types{$type};
					# $words{$type} = [] unless defined $words{$type};
					# my $ref = ref $value;
					# push @{$words{$type}}, ($ref eq 'ARRAY' ? @{$value} : $ref eq 'CODE' ? $value->() : $value);
				# }
			# } elsif (ref $args[0] eq 'CODE') {
				# croak "you cant give back CODEREFs as result of a CODEREF for words";
			# } else {
				# my $type = shift @args;
				# $words{$type} = [] unless defined $words{$type};
				# my $ref = ref $args[0];
				# push @{$words{$type}}, ($ref eq 'ARRAY' ? @{$args[0]} : $ref eq 'CODE' ? $args[0]->() : @args);
			# }
		# };
	# }

}

1;
