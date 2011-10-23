#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);

use Locale::gettext_pp qw(:locale_h :libintl_h);

bindtextdomain('test',$Bin.'/data/locale');
bind_textdomain_codeset('test','utf-8');
textdomain('test');

$ENV{LANG} = 'de_DE';
$ENV{LANGUAGE} = 'de_DE';
$ENV{LC_ALL} = 'de_DE';

is(gettext("Hello"),"Hallo","simple");
is(sprintf(ngettext("You have %d message","You have %d messages",4),4),'Du hast 4 Nachrichten',"simple plural test with plural");
is(sprintf(ngettext("You have %d message","You have %d messages",1),1),'Du hast 1 Nachricht',"simple plural test with single");
is(sprintf(ngettext("You have %d message of %s","You have %d messages of %s",1),1,'harry'),'Du hast 1 Nachricht von harry',"complex plural test with single");
is(sprintf(ngettext("You have %d message of %s","You have %d messages of %s",4),4,'harry'),'Du hast 4 Nachrichten von harry',"complex plural test with plural");

is(sprintf(gettext("Change order test %s %s"),1,2),'Andere Reihenfolge hier 2 1',"changing position test");

done_testing;
