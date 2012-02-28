package DDG::Block;

use Moo::Role;
use Carp;
use Class::Load ':all';

requires qw(
	request
);

has plugins => (
	#isa => 'ArrayRef[Str|HashRef]',
	is => 'ro',
	lazy => 1,
	builder => '_build_plugins',
);

sub _build_plugins { die (ref shift)." requires plugins" }

has return_one => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 1 },
);

has _plugin_objs => (
	# like ArrayRef[ArrayRef[$trigger,DDG::Block::Plugin]]',
	is => 'ro',
	lazy => 1,
	builder => '_build__plugin_objs',
);
sub plugin_objs { shift->_plugin_objs }

sub _build__plugin_objs {
	my ( $self ) = @_;
	my @plugin_objs;
	for (@{$self->plugins}) {
		my $class;
		my %args;
		if (ref $_ eq 'HASH') {
			croak "require a class key in hash" unless defined $_->{class};
			$class = delete $_->{class};
			%args = %{$_};
		} else {
			$class = $_;
		}
		my $plugin;
		if (ref $class) {
			$plugin = $class;
		} else {
			load_class($class);
			$args{block} = $self;
			$plugin = $class->new(\%args);
		}
		my @triggers = $self->get_triggers_of_plugin($plugin);
		@triggers = $self->empty_trigger unless @triggers;
		my @parsed_triggers;
		for (@triggers) {
			push @parsed_triggers, $self->parse_trigger($_);
		}
		push @plugin_objs, [
			\@parsed_triggers,
			$plugin,
		] if @parsed_triggers;
	}
	return \@plugin_objs;
}

sub get_triggers_of_plugin { shift; shift->get_triggers }

sub parse_trigger { shift; shift; }

sub empty_trigger { return undef }

sub run_plugin {
	my ( $self, $plugin, @args ) = @_;
}

sub BUILD {
	my ( $self ) = @_;
	$self->_plugin_objs;
}

1;