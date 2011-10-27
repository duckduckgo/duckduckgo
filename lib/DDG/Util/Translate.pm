package DDG::Util::Translate;
# ABSTRACT: Functions for translate text based on gettext data

use strict;
use warnings;

use Exporter 'import';
use Locale::gettext_pp qw(:locale_h :libintl_h);

use IO::All -utf8;

our @EXPORT = qw(
	
	l_dir
	l_lang
	l_dry

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

my $dry;
my $nowrite;

my %tds;
my $dir;

sub l_dir { $dir = shift }

sub l_lang {
	my $primary = shift;
	$ENV{LANG} = $primary;
	$ENV{LANGUAGE} = $primary;
	$ENV{LC_ALL} = $primary;
}

sub l_dry { $dry = shift, $nowrite = shift }

# write dry
sub wd { io($dry)->append(join("\n",@_)."\n\n") if !$nowrite }

# l(msgid,...)
sub l { return ldnp('',undef,shift,undef,undef,@_) }
# ln(msgid,msgid_plural,count,...)
sub ln { return ldnp('',undef,@_) }
# lp(msgctxt,msgid,...)
sub lp { return ldnp('',shift,shift,undef,undef,@_) }
# lnp(msgctxt,msgid,msgid_plural,count,...)
sub lnp { return ldnp('',shift,shift,shift,shift,@_) }
# ld(domain,msgid,...)
sub ld { return ldnp(shift,undef,shift,undef,undef,@_) }
# ldn(domain,msgid,msgid_plural,count,...)
sub ldn { return ldnp(shift,undef,shift,shift,shift,@_) }
# ldp(domain,msgctxt,msgid,...)
sub ldp { return ldnp(shift,shift,shift,undef,undef,@_) }
# ldnp(domain,msgctxt,msgid,msgid_plural,count,...)
sub ldnp {
	my ($td, $ctxt, $id, $idp, $n) = (shift,shift,shift,shift,shift);
	my @args = @_;
	unshift @args, $n if $idp;
	if ($dry) {
		if (!$nowrite) {
			my @save;
			push @save, '# domain: '.$td if $td;
			push @save, 'msgctxt "'.$ctxt.'"' if $ctxt;
			push @save, 'msgid "'.$id.'"';
			push @save, 'msgid_plural "'.$idp.'"' if $idp;
			wd(@save);
		}
		return sprintf($idp && $n != 1 ? $idp : $id, @args);
	} else {
		return sprintf(dnpgettext($td, $ctxt, $id, $idp, $n),@args);
	}
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