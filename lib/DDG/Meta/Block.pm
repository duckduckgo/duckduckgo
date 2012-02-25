package DDG::Meta::Block;

use strict;
use warnings;
use Carp;

our @words_types = qw(

	after
	before
	around
	any

);

our @regexp_types = qw(

	query_raw
	query
	query_lc
	query_nowhitespace
	query_nowhitespace_nodash
	query_clean

);

my $default_regexp_type = 'query_raw';

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	#
	# words & regexp gathering
	#
	
	{
		my %words;
		my %regexps;
		no strict "refs";

		*{"${target}::all_words_by_type"} = sub { \%words };
		*{"${target}::has_words"} = sub { %words ? 1 : 0 };
		*{"${target}::words"} = sub {
			croak "you can only do regexp or words" if %regexps;
			my @args;
			if (ref $_[0] eq 'CODE') {
				@args = { $_[0]->() };
			} else {
				@args = @_;
			}
			if (ref $args[0] eq 'HASH') {
				my %types = %{$args[0]};
				for my $type (keys %types) {
					croak "unknown type ".$type." for words" unless grep { $_ eq $type } @words_types;
					my $value = $types{$type};
					$words{$type} = [] unless defined $words{$type};
					my $ref = ref $value;
					push @{$words{$type}}, ($ref eq 'ARRAY' ? @{$value} : $ref eq 'CODE' ? $value->() : $value);
				}
			} elsif (ref $args[0] eq 'CODE') {
				croak "you cant give back CODEREFs as result of a CODEREF for words";
			} else {
				my $type = shift @args;
				croak "unknown type ".$type." for words" unless grep { $_ eq $type } @words_types;
				$words{$type} = [] unless defined $words{$type};
				my $ref = ref $args[0];
				push @{$words{$type}}, ($ref eq 'ARRAY' ? @{$args[0]} : $ref eq 'CODE' ? $args[0]->() : @args);
			}
		};

		*{"${target}::all_regexps_by_type"} = sub { \%regexps };
		*{"${target}::has_regexps"} = sub { %regexps ? 1 : 0 };
		*{"${target}::regexp"} = sub {
			croak "you can only do regexp or words" if %words;
			my @args = @_;
			if (ref $args[0] eq 'HASH') {
				my %types = %{$args[0]};
				for my $type (keys %types) {
					croak "unknown type ".$type." for regexp" unless grep { $_ eq $type } @regexp_types;
					my $value = $types{$type};
					$regexps{$type} = [] unless defined $regexps{$type};
					my $ref = ref $value;
					push @{$regexps{$type}}, ($ref eq 'ARRAY' ? @{$value} : $value);
				}
			} elsif (ref $args[0] eq 'CODE') {
				croak "we dont support CODEREFs for regexp";
			} else {
				if (ref $args[0] eq 'Regexp') {
					$regexps{$default_regexp_type} = [] unless defined $regexps{$default_regexp_type};
					push @{$regexps{$default_regexp_type}}, @args;
				} else {
					my $type = shift @args;
					croak "unknown type ".$type." for regexp" unless grep { $_ eq $type } @regexp_types;
					croak "need a regexp for the type" unless @args;
					$regexps{$type} = [] unless defined $regexps{$type};
					my $ref = ref $args[0];
					push @{$regexps{$type}}, ($ref eq 'ARRAY' ? @{$args[0]} : @args);
				}
			}
		};
	}

}

1;
