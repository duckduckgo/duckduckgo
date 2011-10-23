package DDG::Util::Translate;
# ABSTRACT: Functions for translate text based on gettext data

use strict;
use warnings;

use Exporter 'import';
use Locale::gettext_pp qw(:locale_h :libintl_h);

our @EXPORT = qw(
	
	l_dir
	l_lang

	l
	ln
	lp
	lnp
	ld
	ldn
	ldp
	ldnp
	
	ltd

);

my %tds;
my $dir;

sub l_dir { $dir = shift }

sub l_lang {
	my $primary = shift;
	$ENV{LANG} = $primary;
	$ENV{LANGUAGE} = $primary;
	$ENV{LC_ALL} = $primary;
}

sub l { sprintf(gettext(shift),@_) }
sub ln { ldnp('',undef,@_) }
sub lp { sprintf(pgettext(shift,shift),@_) }
sub lnp { ldnp('',@_) }
sub ld { sprintf(dgettext(shift,shift),@_) }
sub ldn { ldnp(shift,undef,@_) }
sub ldp { sprintf(dpgettext(shift,shift,shift),@_) }
sub ldnp {
	my ($td, $ctxt, $id, $idp, $n) = (shift,shift,shift,shift,shift);
	sprintf(dnpgettext($td, $ctxt, $id, $idp, $n),$n,@_)
}

sub ltd {
	die "please set a locale directory with l_dir() before using other translate functions" unless $dir;
	my $td = shift;
	unless (defined $tds{$td}) {
		bindtextdomain($td,$dir);
		bind_textdomain_codeset($td,'utf-8');
		$tds{$td} = 1;
	}
	textdomain($td);
}

1;