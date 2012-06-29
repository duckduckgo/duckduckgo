package DDG::Block;

=head1 DESCRIPTION

This is the base class for the so called Block concept. Its mission is to allow a list of plugins to get used based on specific
trigger types. As an extend you can see L<DDG::Block::Regexp> and L<DDG::Block::Words>.

=cut

use Moo::Role;
use Carp;
use Class::Load ':all';

requires qw(
	request
);

=head1 ATTRIBUTES

=head2 plugins

The list of the plugins used for this block, its an array with a list of strings or hashes. A string defines a class which just
gets regular instantiated via new, if you define a hash the parameter given in this hash are given to the instantiation process
of the class defined by the key "class" inside the hash.

=cut

has plugins => (
	#isa => 'ArrayRef[Str|HashRef]',
	is => 'ro',
	lazy => 1,
	builder => '_build_plugins',
);

sub _build_plugins { die (ref shift)." requires plugins" }

=head2 return_one

This attribute defines if the block should stop if there is a hit which gives a result. By default this is on.

=cut

has return_one => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 1 },
);

=head2 return_one

A coderef that is executed before the build of the plugins. It gets the block object as first and the class name to instantiate
as second parameter.

=cut

has before_build => (
	#isa => 'CodeRef',
	is => 'ro',
	predicate => 'has_before_build',
);

has after_build => (
	#isa => 'CodeRef',
	is => 'ro',
	predicate => 'has_after_build',
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
			if ($self->has_before_build) {
				for ($class) {
					$self->before_build->($self,$class);
				}
			}
			$plugin = $class->new(\%args);
		}
		if ($self->has_after_build) {
			for ($plugin) {
				$self->after_build->($self,$plugin);
			}
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

has only_plugin_objs => (
	is => 'ro',
	lazy => 1,
	builder => '_build_only_plugin_objs',
);
sub _build_only_plugin_objs {
	my ( $self ) = @_;
	my @plugins;
	for (@{$self->_plugin_objs}) {
		push @plugins, $_->[1];
	} 
	return \@plugins;
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