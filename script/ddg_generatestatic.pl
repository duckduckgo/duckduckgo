#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib $FindBin::Dir . "/../lib";

use DDG::App::GenerateStatic;

DDG::App::GenerateStatic->new_with_options();