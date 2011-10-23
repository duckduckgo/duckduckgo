#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use 5.010;

use FindBin qw($Bin);

use Locale::gettext_xs qw(:locale_h :libintl_h);

say $Bin.'/data/locale';

bindtextdomain('test',$Bin.'/data/locale');
textdomain('test');

$ENV{LANG} = 'de_DE';
$ENV{LANGUAGE} = 'de_DE';
$ENV{LC_ALL} = 'de_DE';

is(gettext("Hello"),"Hallo","simple");
is(sprintf(ngettext("You have %d message","You have %d messages",4),4),'Du hast 4 Nachrichten',"simple plural test with plural");
is(sprintf(ngettext("You have %d message","You have %d messages",1),1),'Du hast 1 Nachricht',"simple plural test with single");

is(sprintf(gettext("Change order test %s %s"),1,2),'Andere Reihenfolge hier 2 1',"changing position test");

done_testing;
