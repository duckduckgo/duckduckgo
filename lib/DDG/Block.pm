package DDG::Block;
# ABSTRACT: Block to bundle plugins with triggers

use Moo::Role;
use Carp;
use Class::Load ':all';
use POSIX qw(strftime);

requires qw(
	request
);

sub BUILD {
	my ( $self ) = @_;
	$self->_plugin_objs;
	$self->trace('Loaded block',
		ref $self,
		map {
			$_.':'.( $self->$_ ? 1 : 0 ),
		} qw( return_one allow_missing_plugins allow_duplicate ),
	);
}

=head1 SYNOPSIS

  package DDG::Block::MyType;

  use Moo;
  with qw( DDG::Block );

  sub request { ... }

  1;

as another type of Block (not needed, checkout L<DDG::Block::Words> and L<DDG::Block::Regexp>).

  my $block = DDG::Block::MyType->new( plugins => [qw(
    DDG::Goodie::A
    DDG::Goodie::B
    DDG::Goodie::C
  )] );

or

  package DDG::Block::MyType::BlockA;

  use Moo;
  extends 'DDG::Block::MyType';

  sub _build_plugins {[
    DDG::Goodie::A
    DDG::Goodie::B
    DDG::Goodie::C
  ]}

  1;

=head1 DESCRIPTION

This is the L<Moo::Role> of the so called Block concept. Its mission is to
allow a list of plugins to get used based on specific trigger types. As an
extend you can see L<DDG::Block::Regexp> and L<DDG::Block::Words>.

A class with L<DDG::Block> needs a B<request> function to handle a
L<DDG::Request>. It gets as only parameter the request object and needs to
return a list of results or an empty list. Dont forget that returning B<undef>
on the request function means something depending of the context the
L<DDG::Block> is used.

=attr plugins

The list of the plugins used for this block, its an array with a list of
strings or hashes. A string defines a class which just gets regular
instantiated via new, if you define a hash the parameter given in this hash
are given to the instantiation process of the class defined by the key "class"
inside the hash.

=cut

has plugins => (
	#isa => 'ArrayRef[Str|HashRef]',
	is => 'ro',
	lazy => 1,
	builder => '_build_plugins',
);

sub _build_plugins { die (ref shift)." requires plugins" }

=attr allow_missing_plugins

This attribute defines if the block should die on missing plugins, or if he
should just go on. If given a CODEREF, then this CODEREF will get executed
with the block as first parameter, and the missing class name as second. By
default this is disabled.

=cut

has allow_missing_plugins => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 0 },
);

=attr return_one

This attribute defines if the block should stop if there is a hit which gives
a result. By default this is on.

=cut

has return_one => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 1 },
);

=attr allow_duplicate

This attribute defines if the block is only allowing one instance of every
plugin be called once, even if they hit cause of several cases. By default
this is off, and should stay off.

=cut

has allow_duplicate => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { 0 },
);

=attr debug_trace

=cut

has debug_trace => (
	#isa => 'Bool',
	is => 'ro',
	default => sub { defined $ENV{DDG_BLOCK_TRACE} && $ENV{DDG_BLOCK_TRACE} ? 1 : 0 },
);

sub trace {
	my $self = shift;
	return unless $self->debug_trace;
    $|=1;
	print STDERR ("[".$self->trace_name."] ",join(" ",map { defined $_ ? $_ : 'undef' } @_),"\n");
}

sub trace_name { ref(shift) }

=attr before_build

A coderef that is executed before the build of the plugins. It gets the block
object as first and the class name to instantiate as second parameter.

=cut

has before_build => (
	#isa => 'CodeRef',
	is => 'ro',
	predicate => 'has_before_build',
);

=attr after_build

A coderef that is executed before the build of the plugins. It gets the block
object as first and the object of the plugin as second parameter.

=cut

has after_build => (
	#isa => 'CodeRef',
	is => 'ro',
	predicate => 'has_after_build',
);

=attr plugin_objs

This private attribute contains an array with an arrayref of trigger and 
plugin, its the main point where all subclasses of Blocks fetches the plugin
=E<gt> triggers definition. Do never set this attribute yourself, or you are
doomed ;). The generation of this array also instantiates the plugins, which
makes it an important point for the general handling plugins who needs
L</after_build> and L</before_build>. It gets triggered on instantiation of the
Block.

The function goes through all plugin class names given on the setup of the blog

=cut

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
			unless (try_load_class($class)) {
				if ($self->allow_missing_plugins) {
					if (ref $self->allow_missing_plugins eq 'CODE') {
						$self->allow_missing_plugins->($self,$class);
					}
				} else {
					die "Can't load plugin ".$class;
				}
				next;
			}
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

=attr only_plugin_objs

This read-only attribute contains an arrayref of all plugins in a row. This can be used to iterate over all objects
more easy then using L</plugin_objs>. It gets generated only on usage and takes L</plugin_objs> as source.

=cut

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

=method get_triggers_of_plugin

Get called to find all the triggers given by a specific plugin. If your Block subclass requires
a special handling here, then it can be overloaded and just behave like you require. It gets the object of the
plugin as first parameter.

=cut

sub get_triggers_of_plugin { shift; shift->get_triggers }

=method parse_trigger

Gets called for every single trigger of a plugin to parse out and sort out. By default it doesnt do
anything, but as the other functions you can overload this behaviour.

=cut

sub parse_trigger { shift; shift; }

=method empty_trigger

Gets called, if the plugin doesnt deliver any trigger, here you can wrap this to your own specific
definition. Its so far only used in the L<DDG::Block::Words>, to disallow empty triggers totally. By default
it returns B<undef>.

=cut

sub empty_trigger { return undef }

=method handle_request_matches

This function is used for calling I<handle_request_matches> on the plugin,
which is implemented there via L<DDG::Meta::RequestHandler>.

=cut

sub handle_request_matches {
	my ( $self, $plugin, $request, @args ) = @_;
	my $plugin_class = ref $plugin;
	$self->trace('Handle request matches:',$plugin_class,"'".$request->query_raw."'",@args);
	unless ($self->allow_duplicate) {
		if (grep { $_ eq $plugin_class } @{$request->seen_plugins}) {
			$self->trace("The request already saw",$plugin_class);
			return ();
		}
	}
	push @{$request->seen_plugins}, $plugin_class;
	my @results = $plugin->handle_request_matches($request, @args);
	$self->trace("Got",scalar @results,"results");
	return @results;
}

around request => sub {
	my $orig = shift;
	my ( $self, $request ) = @_;
	$self->trace( "Query raw:", "'".$request->query_raw."'" );
	my @results = $orig->(@_);
	$self->trace( "Query", "'".$request->query_raw."'", "produced", scalar @results, "results" );
	return @results;
};

1;
