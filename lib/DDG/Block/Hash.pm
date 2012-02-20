package DDG::Block::Hash;

use Moo;
with qw( DDG::Block );

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

sub request {
	my ( $self, $request ) = @_;
	my @words = @{$self->case_sensitive ? $request->words : $request->lc_words};
	return unless @words;
	my @results;
	for (0..(scalar @words-1)) {
		if (defined $self->plugin_objs_hash->{$_}) {
			my $hit = $_;
			my $is_hit = 0;
			my @before; my @after;
			for (@{$self->words}) {
				if ($_ eq $hit) {
					$is_hit = 1;
				} else {
					if ($is_hit) {
						push @after, $_;
					} else {
						push @before, $_;
					}
				}
			}
			my @return = $self->plugin_objs_hash->{$hit}->query($query,[\@before,$hit,\@after],@args);
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