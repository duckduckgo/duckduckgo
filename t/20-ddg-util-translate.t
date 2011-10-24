#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8;

use FindBin qw($Bin);

use DDG::Util::Translate;

l_dir($Bin.'/data/locale');
ltd('test');
l_lang('de_DE');

is(
	l("Hello"),
	"Hallo",
	"simple"
);

is(
	ln("You have %d message","You have %d messages",4),
	'Du hast 4 Nachrichten',
	"simple plural test with plural"
);

is(
	ln("You have %d message","You have %d messages",1),
	'Du hast 1 Nachricht',
	"simple plural test with single"
);

is(
	ln("You have %d message of %s","You have %d messages of %s",1,'harry'),
	'Du hast 1 Nachricht von harry',
	"complex plural test with single"
);

is(
	ln("You have %d message of %s","You have %d messages of %s",4,'harry'),
	'Du hast 4 Nachrichten von harry',
	"complex plural test with plural"
);

is(
	l("Change order test %s %s",1,2),
	'Andere Reihenfolge hier 2 1',
	"changing position test"
);

done_testing;
