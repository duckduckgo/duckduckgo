#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib $FindBin::Dir . "/../lib";

use DDGC::App::GenerateStatic;

DDGC::App::GenerateStatic->new_with_options();