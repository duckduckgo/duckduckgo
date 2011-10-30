package DDG::Site::DuckDuckGo;

use Moose;
extends 'DDG::Site';

sub key { 'duckduckgo' }

sub default_stash {{}}

sub locales { 'en_US', 'de_DE', }

sub _build_statics {
	my ( $self ) = @_;
	$self->get_locale_statics('settings','html','settings',{}),
	$self->get_locale_statics('spread','html','spread',{}),
}

1;