#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('DDG');
    use_ok('DDG::App');
    use_ok('DDG::App::GenerateStatic');
    use_ok('DDG::Block');
    use_ok('DDG::Block::Hash');
    use_ok('DDG::Block::Regexp');
    use_ok('DDG::Dir::Static');
    use_ok('DDG::File::Static');
    use_ok('DDG::Plugin');
    use_ok('DDG::Plugin::Sample::Hash');
    use_ok('DDG::Plugin::Sample::Regexp');
    use_ok('DDG::Plugin::Sample::Regexp::Matches');
    use_ok('DDG::Plugin::ZeroClickInfo');
    use_ok('DDG::Query');
    use_ok('DDG::Site');
    use_ok('DDG::Site::DuckDuckGo');
    use_ok('DDG::Util::Translate');
    use_ok('DDG::ZeroClickInfo');
}

done_testing;
