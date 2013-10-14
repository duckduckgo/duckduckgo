package DDG::Goodie::Teredo;
# ABSTRACT: Provides the Teredo server IPv4 address,
# NAT IPv4 address, and port number encoded in a given
# Teredo tunnel IPv6 address.

use DDG::Goodie;
use Net::IP;
use Math::BaseConvert;

=keyword primary_example_queries

"teredo 2001:0000:4136:e378:8000:63bf:3fff:fdd2";
"teredo 2001::CE49:7601:E866:EFFF:62C3:FFFE";

=cut

=keyword description

"Teredo address analyzer";

=cut

=keyword name

"Teredo extractor";

=cut

=keyword code_url

"https://github.com/duckduckgo/lib/DDG/Goodie/Teredo.pm";

=cut

=keyword topics

"sysadmin";

=cut

=keyword category

"transformations";

=cut

=keyword attribution

github => ['https://github.com/seanheaton','seanheaton'],
twitter => ['http://twitter.com/seanograph','@seanograph'],
email => ['mailto:seanoftime@gmail.com','seanoftime@gmail.com'];

=cut

triggers start => 'teredo';

handle remainder => sub {

	my $ip = new Net::IP ($_,6) if $_;

		if ((defined $ip) && ($ip->version() == 6) && (substr($ip->ip(),0,9) eq "2001:0000")) {
			my $binip = $ip->binip();
			my $server = new Net::IP (Net::IP::ip_bintoip((substr $binip, 32, 32),4));
			my $port = 65535 - cnv((substr $binip, 80, 16),2,10);
			my $client = new Net::IP (Net::IP::ip_bintoip(~(substr $binip, 96, 32),4));
			return "Teredo Server IPv4: " . $server->ip() . "\nNAT Public IPv4: " . $client->ip() . "\nClient Port: " . $port;
		}
	return;
};
zci is_cached => 1;
1;
