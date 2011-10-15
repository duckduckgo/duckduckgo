package DDG::App::GenerateStatic;

use Moose;
extends 'DDG::App';

has targetdir => (
	isa => 'Str',
	is => 'ro',
	required => 1,
);

has _target => (
	traits => [qw( NoGetopt )],
	isa => 'Str',
	is => 'ro',
	lazy_build => 1,
);
sub target { shift->_target }

sub _build__target {
	my ( $self ) = @_;
	return $self->targetdir if File::Spec->file_name_is_absolute($self->targetdir);
	return File::Spec->rel2abs($self->targetdir);
}

has podir => (
	isa => 'Str',
	is => 'ro',
	required => 1,
);

has _pos => (
	traits => [qw( NoGetopt )],
	isa => 'Str',
	is => 'ro',
	lazy_build => 1,
);
sub pos { shift->_pos }

sub _build__pos {
	my ( $self ) = @_;
	return $self->targetdir if File::Spec->file_name_is_absolute($self->podir);
	return File::Spec->rel2abs($self->podir);
}

has site => (
	isa => 'Str',
	is => 'ro',
	required => 1,
);

sub BUILD {
	my ( $self ) = @_;
	$self->error($self->target." is not writeable") unless -w $self->target;
}

1;