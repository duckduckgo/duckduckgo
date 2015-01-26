package DDG;
# ABSTRACT: DuckDuckGo Search Engines Open Source Parts

=head1 DESCRIPTION

This is the main DDG class which is right now only used for storing the function for getting the not yet used template directory.
Longtime it will get probably a kind of metaclass or stays a general configuration class. Please dont use it for anything.

=cut

use strict;
use warnings;

use File::ShareDir::ProjectDistDir;

use Exporter 'import';

our @EXPORT = qw( templates_dir );

sub templates_dir { File::Spec->rel2abs( File::Spec->catfile(dist_dir('DDG'), 'templates') ) }

1;
