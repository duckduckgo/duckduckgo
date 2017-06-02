package DDG::Block::Blockable::Triggers;
# ABSTRACT: A package which reflects the triggers of a blockable plugin.

use Moo;
use Carp;

our @words_types = qw(

	start
	end
	startend
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

our $default_regexp_type = 'query_raw';

has triggers => (
	is => 'ro',
	default => sub {{}},
);

has block_type => (
	is => 'rw',
	predicate => 'has_block_type',
);

has has_triggers => (
	is      => 'ro',
	default => 0,
);

sub get { shift->triggers }

sub add {
	my ( $self, @args ) = @_;
	my %params;
	if (ref $args[0] eq 'CODE') {
		%params = $args[0]->();
	} elsif (ref $args[0] eq 'HASH') {
		%params = %{$args[0]};
	} elsif (ref $args[0] eq 'Regexp') {
		%params = ( $default_regexp_type => [@args] );
	} else {
		my @words;
		if (ref $args[1] eq 'ARRAY') {
			@words = grep { defined } @{$args[1]};
		}
		elsif (scalar @args > 2) {
			@words = grep { defined } @args[1..(scalar @args-1)];
		}
		else {
			%params = ( $args[0] => $args[1] ) if defined $args[1];
		}
		%params = ( $args[0] => \@words ) if @words;
	}
	$self->{has_triggers} = 1 if (keys %params);
	for (keys %params) {
		my $trigger_type = $_;
		my @triggers = ref $params{$trigger_type} eq 'ARRAY' ? @{$params{$trigger_type}} : ($params{$trigger_type});
		croak 'no trigger values given' unless @triggers;
		$self->add_triggers($trigger_type, @triggers);
	}
}

sub add_triggers {
	my ( $self, $trigger_type, @add_triggers ) = @_;
	my @triggers;
	for (@add_triggers) {
		push @triggers, ref $_ eq 'CODE' ? $_->() : $_;
	}
	if (grep { $_ eq $trigger_type } @words_types) {
		croak "You can't add trigger types of the other block-type" if $self->has_block_type && $self->block_type ne 'Words';
		$self->block_type('Words');
	} elsif (grep { $_ eq $trigger_type } @regexp_types) {
		croak "You can't add trigger types of the other block-type" if $self->has_block_type && $self->block_type ne 'Regexp';
		$self->block_type('Regexp');
		for (@triggers) {
			croak 'You may only give compiled regexps to regexp trigger types (like qr/reverse (.*)/i)' unless ref $_ eq 'Regexp';
		}
	}
	croak "your trigger_type '".$trigger_type."' is unknown" unless $self->has_block_type;
	push @{$self->triggers->{$_}}, @triggers;
}

1;
