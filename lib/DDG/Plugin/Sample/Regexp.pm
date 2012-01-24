package DDG::Plugin::Sample::Regexp;

use Moo;
with qw( DDG::Plugin );

sub triggers { qr{^bla}, qr{blub}, qr{^someregexp$} }

sub simple_query { shift; 'I was hit cause of query "'.(shift).'"' }

1;