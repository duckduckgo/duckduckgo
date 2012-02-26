#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok('DDG');
    use_ok('DDG::Block');
    use_ok('DDG::Block::Words');
    use_ok('DDG::Block::Regexp');
    use_ok('DDG::Request');
    use_ok('DDG::ZeroClickInfo');

	# use_ok('DDG::Dir::Static');
	# use_ok('DDG::File::Static');
	# use_ok('DDG::Site');
	# use_ok('DDG::Site::DuckDuckGo');

}

done_testing;
