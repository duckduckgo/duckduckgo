#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use IO::All;
use utf8;

use FindBin qw($Bin);

use DDG::Util::Translate;

use File::Temp qw/ tempfile tempdir /;

my $tmpdir = tempdir();

l_dry($tmpdir.'/dryrun.po');

is(
	l("Hello"),
	"Hello",
	"simple"
);

is(
	ln("You have %d message","You have %d messages",4),
	'You have 4 messages',
	"dryrun simple plural test with plural"
);

is(
	ln("You have %d message","You have %d messages",1),
	'You have 1 message',
	"dryrun simple plural test with single"
);

is(
	ln("You have %d message of %s","You have %d messages of %s",1,'harry'),
	'You have 1 message of harry',
	"dryrun complex plural test with single"
);

is(
	ln("You have %d message of %s","You have %d messages of %s",4,'harry'),
	'You have 4 messages of harry',
	"dryrun complex plural test with plural"
);

is(io($tmpdir.'/dryrun.po')->slurp,<<__EOT__,'checking generated po');
msgid "Hello"

msgid "You have %d message"
msgid_plural "You have %d messages"

msgid "You have %d message"
msgid_plural "You have %d messages"

msgid "You have %d message of %s"
msgid_plural "You have %d messages of %s"

msgid "You have %d message of %s"
msgid_plural "You have %d messages of %s"

__EOT__

done_testing;
