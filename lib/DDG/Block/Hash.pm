package DDG::Block::Hash;

use Moo;
with qw( DDG::Block );

use Class::Load ':all';

has all_words => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 0 },
);

has case_sensitive => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 0 },
);

has _plugin_objs_hash => (
	# like HashRef[DDG::Block::Plugin]',
	is => 'ro',
	lazy => 1,
	builder => '_build__plugin_objs_hash',
);
sub plugin_objs_hash { shift->_plugin_objs_hash }

sub _build__plugin_objs_hash {
	my ( $self ) = @_;
	my %hash;
	for (@{$self->plugin_objs}) {
		my $triggers = $_->[0];
		my $plugin = $_->[1];
		for (@{$triggers}) {
			$hash{$_} = $plugin;
		}
	}
	return \%hash;
}

sub query {
	my ( $self, $query, @args ) = @_;
	my @words = @{$query->words};
	return unless @words;
	my @search_words = $self->all_words ? @words : $words[0];
	my @filtered_search_words;
	for (@search_words) {
		push @filtered_search_words, $_ unless $_ eq '';
	}
	return unless @filtered_search_words;
	my @results;
	for (@filtered_search_words) {
		if (defined $self->plugin_objs_hash->{$_}) {
			my $hit = $_;
			my @params;
			push @params, $hit;
			for (@words) {
				push @params, $_ if $_ ne $hit;
			}
			my @return = $self->plugin_objs_hash->{$hit}->query($query,\@params,@args);
			if (@return) {
				if ($self->return_one || !$self->all_words) {
					return @return;
				} else {
					push @results, $_ for @return;
				}
			}
		}
	}
	return @results;
}

sub parse_trigger {
	my ( $self, $trigger ) = @_;
	return lc($trigger) unless $self->case_sensitive;
	return "".$trigger;
}

sub empty_trigger {}

sub BUILD {
	my ( $self ) = @_;
	$self->plugin_objs_hash;
}

1;