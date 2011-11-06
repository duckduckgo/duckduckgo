package DDG::Site;

use Moose;
use Template;
use File::Spec;
use File::ShareDir::ProjectDistDir;
use DDG::Util::Translate;
use HTML::Packer;

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
		WRAPPER => 'base.tt',
	});
}

has packed => (
	is => 'ro',
	isa => 'Bool',
	lazy_build => 1,
);
sub _build_packed { 1 }

has packer => (
	isa => 'HTML::Packer',
	is => 'ro',
	lazy_build => 1,
);
sub _build_packer {
	HTML::Packer->init()
}

has statics => (
	is => 'ro',
	isa => 'HashRef',
	lazy_build => 1,
);
sub _build_statics {{}}

has locale_urls => (
	is => 'ro',
	isa => 'HashRef',
	lazy_build => 1,
);
sub _build_locale_urls {{}}

sub minify {
	my ( $self, $contentref ) = @_;
	$self->packer->minify($contentref,{
		remove_comments => 1,
		remove_newlines => 1,
		do_javascript => 'shrink',
		do_stylesheet => 'minify',
	});
}

sub locale_url {
	my ( $self, $basename, $locale ) = @_;
	defined $locale && defined $self->locale_urls->{$basename} &&
	defined $self->locale_urls->{$basename}->{$locale} ?
	$self->locale_urls->{$basename}->{$locale} :
	$self->root.$basename.$self->suffix;
}

has suffix => (
	is => 'ro',
	isa => 'Str',
	lazy_build => 1,
);
sub _build_suffix { '.html' }

has root => (
	is => 'ro',
	isa => 'Str',
	lazy_build => 1,
);
sub _build_root { '/' }

sub get_locale_statics {
	my ( $self, $basename, $template, $stash ) = @_;
	$self->locale_urls->{$basename} = {};
	my %statics;
	for ($self->locales) {
		my $filename = $basename.($_ eq $self->default_locale ? '' : '.'.$_ ).$self->suffix;
		if ($basename eq 'index' and $_ eq $self->default_locale) {
			$self->locale_urls->{$basename}->{$_} = $self->root;
		} else {
			$self->locale_urls->{$basename}->{$_} = $self->root.$filename;
		}
		$statics{$filename} = {
			template => $template,
			stash => {
				%$stash,
				site => $self,
				basename => $basename,
				filename => $filename,
				locale => $_,
			},
		};
	}
	return %statics;
}

sub files {
	my ( $self ) = @_;
	my %f;
	for ( keys %{$self->statics} ) {
		my $filename = $_;
		my $config = $self->statics->{$_};
		my $template = delete $config->{template};
		my $stash = delete $config->{stash};
		my $content = $self->generate($template,$stash);
		$self->minify(\$content) if ($self->packed);
		$f{$filename} = $content;
	}
	return \%f;
}

sub generate {
	my ( $self, $template, $stash ) = @_;
	my $content;
	if ($self->can('default_stash')) {
		for (keys %{$self->default_stash}) {
			$stash->{$_} = $self->default_stash->{$_} unless defined $stash->{$_};
		}
	}
	$stash->{$_} = DDG::Util::Translate->coderef_hash->{$_} for (keys %{DDG::Util::Translate->coderef_hash});
	$stash->{u} = sub { $self->locale_url(@_) };
	$stash->{root} = $self->root;
	$self->tt->process($template.".tt", $stash, \$content) || die $self->tt->error(), "\n";
	return $content;
}

1;