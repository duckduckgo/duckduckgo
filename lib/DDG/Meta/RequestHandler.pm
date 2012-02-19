package DDG::Meta::RequestHandler;

use strict;
use warnings;
use Carp;
require Moo::Role;

my @request_attributes = qw(

	query_unmodified
	nowhitespaces
	nowhitespaces_nodashes
	query
	words
	words_unmodified
	lc_query
	wordcount
	wordcount_unmodified
	lc_words

);

my $default_handler = 'lc_words';

sub apply_keywords {
	my ( $class, $target, $result_handler ) = @_;
	
	{
		no strict "refs";

		*{"${target}::handle"} = sub {
			my $handler = shift;
			my $code;
			if (ref $handler eq 'CODE') {
				$code = $handler;
				$handler = $default_handler;
			} else {
				$code = shift;
			}
			if (grep { $_ eq $handler } @request_attributes) {
				*{"${target}::handle_request_matches"} = sub {
					my ( $self, $request, $matches ) = @_;
					my $result = $code->($request->$handler);
					return $result ? $result_handler->($self,$result) : ();
				};
			} elsif ($handler eq 'request') {
				*{"${target}::handle_request_matches"} = sub {
					my ( $self, $request, $matches ) = @_;
					my $result = $code->($request);
					return $result ? $result_handler->($self,$result) : ();
				};
			} elsif ($handler eq 'remainder' || $handler eq 'lc_remainder') {

			} elsif ($handler eq 'matches' || $handler eq 'lc_matches') {

			} else {
				croak "I dont know how to handle ".$handler."!";
			}
		};
	}

}

1;
