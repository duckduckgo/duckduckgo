#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use 5.010;

use FindBin qw($Bin);

use Locale::gettext_pp qw(:locale_h :libintl_h);

say $Bin.'/data/locale';

bindtextdomain('test',$Bin.'/data/locale');
textdomain('test');

$ENV{LANG} = 'de_DE';
$ENV{LANGUAGE} = 'de_DE';
$ENV{LC_ALL} = 'de_DE';

say gettext("Hello");
say ngettext("You have %d message","You have %d messages",4);

done_testing;
