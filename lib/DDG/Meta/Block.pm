package DDG::Meta::Block;

use strict;
use warnings;
use Carp;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	#
	# words & regexp gathering
	#
	
	{
		my %words;
		my @res;
		no strict "refs";

		*{"${target}::all_words_by_type"} = sub { \%words };
		*{"${target}::has_words"} = sub { %words ? 1 : 0 };
		*{"${target}::words"} = sub {
			croak "you can only do regexp or words" if @res;
			my @args;
			if (ref $_[0] eq 'CODE') {
				@args = { $_[0]->() };
			} else {
				@args = @_;
			}
			if (ref $args[0] eq 'HASH') {
				my %types = %{$args[0]};
				for my $type (keys %types) {
					my $value = $types{$type};
					$words{$type} = [] unless defined $words{$type};
					my $ref = ref $value;
					push @{$words{$type}}, ($ref eq 'ARRAY' ? @{$value} : $ref eq 'CODE' ? $value->() : $value);
				}
			} elsif (ref $args[0] eq 'CODE') {
				croak "you cant give back CODEREFs as result of a CODEREF for words";
			} else {
				my $type = shift @args;
				$words{$type} = [] unless defined $words{$type};
				my $ref = ref $args[0];
				push @{$words{$type}}, ($ref eq 'ARRAY' ? @{$args[0]} : $ref eq 'CODE' ? $args[0]->() : @args);
			}
		};

		*{"${target}::all_regexps"} = sub { @res };
		*{"${target}::has_regexps"} = sub { @res ? 1 : 0 };
		*{"${target}::regexp"} = sub {
			croak "you can only do regexp or words" if %words;
			for (@_) {
				my @arg_res = (ref $_ eq 'CODE' ? $_->() : ref $_ eq 'ARRAY' ? @{$_} : $_);
				for (@arg_res) {
					die 'regexp need to be a compiled regexp qr{...}' unless ref $_ eq 'Regexp';
					push @res, $_;
				}
			}
		};
	}

}

1;
