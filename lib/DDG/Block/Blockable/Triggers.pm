package DDG::Block::Blockable::Triggers;
# ABSTRACT: A package which reflects the triggers of a blockable plugin.

use Moo;
use Carp;
use Data::Printer;

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

sub get { shift->triggers }

sub add {
	my ( $self, @args ) = @_;
	warn "adding: ", p(@args);
	my %params;
	if (ref $args[0] eq 'CODE') { # None of the repos seem to use this
		warn "CODE: ", p($args[0]);
		%params = $args[0]->();
	} elsif (ref $args[0] eq 'HASH') {
		warn "HASH";
		%params = %{$args[0]};
	} elsif (ref $args[0] eq 'Regexp') {
		warn "Regexp";
		%params = ( $default_regexp_type => [@args] );
	} else { # Words
		warn "OTHER";
		if (scalar @args > 2) {
			%params = ( $args[0] => [@args[1..(scalar @args-1)]] );
		} else {
			%params = ( $args[0] => $args[1] );
		}
	}
	warn "params: ", p(%params);
	for (keys %params) {
		my $trigger_type = $_;
		my @triggers = ref $params{$trigger_type} eq 'ARRAY' ? @{$params{$trigger_type}} : ($params{$trigger_type});
		croak 'no trigger values given' unless @triggers;
		$self->add_triggers($trigger_type, @triggers);
	}
}

sub add_triggers {
	my ( $self, $trigger_type, @add_triggers ) = @_;
	warn "trigger_type: $trigger_type";
	warn "add_triggers: @add_triggers";
	my @triggers;
	for (@add_triggers) {
		warn "CODE: ", p($_) if ref $_ eq 'CODE';
		push @triggers, ref $_ eq 'CODE' ? $_->() : $_;
	}
	warn "\$_ : $_";
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
	else{
		croak "your trigger_type '".$trigger_type."' is unknown";
	}
	warn "\$_: ", p($_);
	#$self->triggers->{$_} = [] unless defined $self->triggers->{$_};
	# Why are we using the opaque $_, can't even discern where it gets set, instead of $trigger_type?!
	# Could not find *any* IA for which the following was true
	if($_ ne $trigger_type){ warn "$_ ne $trigger_type"; }
	push @{$self->triggers->{$trigger_type}}, @triggers;
	warn "self->triggers: ", p($self->triggers);
}

1;
