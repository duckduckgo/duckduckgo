package DDG::Plugin::Sample::Regexp::Matches;

use Moo;
with qw( DDG::Plugin );

sub triggers { qr{^reverse (.*)$} }

sub simple_query {
	my ( $self, $query, $match ) = @_;
	reverse($match);
}

1;