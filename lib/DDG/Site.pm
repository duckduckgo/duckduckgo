package DDG::Site;

use Moose;
use Template;
use File::Spec;
use File::ShareDir::ProjectDistDir;
use DDG::Util::Translate;

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
sub _build_statics {{}}

has locale_urls => (
	is => 'ro',
	isa => 'HashRef',
	lazy_build => 1,
);
sub _build_locale_urls {{}}

sub locale_url {
	my ( $self, $basename, $locale ) = @_;
	defined $self->locale_urls->{$basename}->{$locale} ?
	$self->locale_urls->{$basename}->{$locale} :
	$basename.$self->suffix;
}

has suffix => (
	is => 'ro',
	isa => 'Str',
	lazy_build => 1,
);
sub _build_suffix { '.html' }

sub get_locale_statics {
	my ( $self, $basename, $template, $stash ) = @_;
	$self->locale_urls->{$basename} = {};
	for ($self->locales) {
		if ($_ eq $self->default_locale) {
			$self->locale_urls->{$basename}->{$_} = $basename.$self->suffix;
		} else {
			$self->locale_urls->{$basename}->{$_} = $basename.'.'.$_.$self->suffix;
		}
	}
	my %statics;
	for ($self->locales) {
		my $filename = $self->locale_url($basename,$_);
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
		use DDP;
		p($template);
		p($stash);
		$f{$filename} = $self->generate($template,$stash);
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
	$self->tt->process($template.".tt", $stash, \$content) || die $self->tt->error(), "\n";
	return $content;
}

1;