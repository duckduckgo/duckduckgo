package DDGTestSite;

use Moose;
extends 'DDG::Site';

use FindBin qw($Bin);

sub key { 'testsite' }

has test_template_dir => (
	isa => 'Str',
	is => 'ro',
	required => 1,
);

sub template_dir { shift->test_template_dir };

sub default_stash {{
	a => 'a',
	d => 'd',
}}

sub locales { 'en_US', 'de_DE', }

sub _build_statics {
	my ( $self ) = @_;
	return {
		$self->get_locale_statics('index','html','index.tt',{
			b => 'b',
			d => 'b',
		}),
		$self->get_locale_statics('test','html','test.tt',{
			c => 'c',
			d => 'c',
		}),
	};
}

1;