package DDG::Plugin::Sample::Regexp::Matches;

use Moo;
with qw( DDG::Plugin );

sub triggers { qr{^[ \t\n]*reverse (.*)$} }

sub simple_query {
	my ( $self, $query, $match ) = @_;
	join('',reverse(split(//,$match)));
}

1;