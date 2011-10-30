#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use DDGTestSite;

my $site = DDGTestSite->new( test_template_dir => "$Bin/templates/testsite" );

isa_ok($site,'DDGTestSite');

my %files = $site->files;
my $stash = {
          'test.en_US.html' => '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Testa</title>
</head>
<body id="index" class="home">
:c:c
</body>
</html>',
          'test.de_DE.html' => '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Testa</title>
</head>
<body id="index" class="home">
:c:c
</body>
</html>',
          'index.de_DE.html' => '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Indexa</title>
</head>
<body id="index" class="home">
b::b
</body>
</html>',
          'index.en_US.html' => '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>Indexa</title>
</head>
<body id="index" class="home">
b::b
</body>
</html>'
};

is_deeply( \%files, $stash ,'generate testsite');

done_testing;
