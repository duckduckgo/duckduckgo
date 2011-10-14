package DDG::Util::Translate;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT = qw( l l_set_locales l_add_context l_set_context );

use Data::Localize;
use IO::All;

my %cons;
my @locales;
my $current;

sub l { $current->localize(@_) }

sub l_add_context {
	my $contextname = shift;
	my $contextdir = shift;
	die "[DDG::Util::Translate] need contextname and contextdir" unless $contextname && $contextdir;
	$cons{$contextname} = Data::Localize->new();
	$cons{$contextname}->add_localizer(
		class => 'Gettext',
		path => $contextdir.'/*.po',
	);
	$cons{$contextname}->set_languages(@locales);
}

sub l_set_locales {
	@locales = @_;
	$_->set_languages(@locales) for (values %cons);
}

sub l_set_context {
	my $contextname = shift;
	die "[DDG::Util::Translate] need contextname" unless $contextname;
	die "[DDG::Util::Translate] requested context ".$contextname." is not loaded" unless defined $cons{$contextname};
	$current = $cons{$contextname};
}

1;