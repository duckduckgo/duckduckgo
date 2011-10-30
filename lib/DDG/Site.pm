package DDG::Site;

use Moose;
use Template;
use File::Spec;
use File::ShareDir::ProjectDistDir;

sub key { die "please overwrite key" }
sub locales { die "please overwrite locales" }

sub default_locale {
	my ( $self ) = @_;
	my @locales = $self->locales;
	return $locales[0];
}

sub template_dir { File::Spec->rel2abs( File::Spec->catfile( dist_dir('DDG'), 'templates', shift->key ) ) };

has tt => (
	isa => 'Template',
	is => 'ro',
	lazy_build => 1,
);
sub _build_tt {
	my ( $self ) = @_;
	Template->new({
		INCLUDE_PATH => $self->template_dir,
		TEMPLATE_EXTENSION => '.tt',
		render_die => 1,
		START_TAG => '<@',
		END_TAG => '@>',
	});
}

has statics => (
	is => 'ro',
	isa => 'HashRef',
	lazy_build => 1,
);
sub _build_statics {}

sub get_locale_statics {
	my ( $self, $basename, $suffix, $template, $stash ) = @_;
	my %s;
	for ($self->locales) {
		my $filename = $basename.'.'.$_.'.'.$suffix;
		$s{$filename} = {
			template => $template,
			stash => {
				%$stash,
				locale => $_,
			},
		}
	}
	return %s;
}

sub files {
	my ( $self ) = @_;
	my %f;
	for ( keys %{$self->statics} ) {
		my $filename = $_;
		my $config = $self->statics->{$_};
		my $template = delete $config->{template};
		my $stash = delete $config->{stash};
		$f{$filename} = $self->generate($template,$stash);
	}
	return %f;
}

sub generate {
	my ( $self, $template, $stash ) = @_;
	my $content;
	if ($self->can('default_stash')) {
		for (keys %{$self->default_stash}) {
			$stash->{$_} = $self->default_stash->{$_} unless defined $stash->{$_};
		}
	}
	$self->tt->process($template, $stash, \$content) || die $self->tt->error(), "\n";
	return $content;
}

1;