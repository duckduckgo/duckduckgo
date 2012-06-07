package DDG;
# ABSTRACT: DuckDuckGo Search Engines Open Source Parts

use strict;
use warnings;

our $VERSION ||= '9.999';

use File::ShareDir::ProjectDistDir;

use Exporter 'import';

our @EXPORT = qw( templates_dir );

sub templates_dir { File::Spec->rel2abs( File::Spec->catfile(dist_dir('DDG'), 'templates') ) }

1;
