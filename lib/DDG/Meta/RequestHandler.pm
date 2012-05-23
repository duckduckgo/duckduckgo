package DDG::Meta::RequestHandler;

use strict;
use warnings;
use Carp;
use Package::Stash;
require Moo::Role;

my @request_scalar_attributes = qw(

	query_raw
	query_nowhitespace
	query_nowhitespace_nodash
	query
	query_lc
	query_clean
	wordcount

);

my @request_array_attributes = qw(

	words
	query_parts
	query_raw_parts

);

my $default_handler = 'query_raw';

sub apply_keywords {
	my ( $class, $target, $result_handler, $role ) = @_;
	
	my $stash = Package::Stash->new($target);

	$stash->add_symbol('&handle',sub {
		my $handler = shift;
		my $code;
		if (ref $handler eq 'CODE') {
			$code = $handler;
			$handler = $default_handler;
		} else {
			$code = shift;
			croak "We need a CODEREF for the handler" unless ref $code eq 'CODE';
		}
		croak "Please define triggers before you define a handler" unless $target->has_triggers;
		if (grep { $_ eq $handler } @request_scalar_attributes) {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				my @result;
				for ($request->$handler) {
					@result = $code->($_);
				}
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif (grep { $_ eq $handler } @request_array_attributes) {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				my @result;
				for ($request->$default_handler) {
					@result = $code->(@{$request->$handler});
				}
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif ($handler eq 'request') {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				my @result;
				for ($request) {
					@result = $code->($_);
				}
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif ($handler eq 'remainder' || $handler eq 'remainder_lc') {
			croak "You must be using words matching for remainder handler" unless $target->triggers_block_type eq 'Words';
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request, $from_pos, $to_pos ) = @_;
				my $remainder = $request->generate_remainder($from_pos,$to_pos);
				my @result;
				for ($handler eq 'remainder' ? $remainder : lc($remainder)) {
					@result = $code->($_);
				}
				return @result ? $result_handler->($self, @result) : ();
			});
		} elsif ($handler eq 'matches') {
			croak "You must be using regexps matching for matches handler" unless $target->triggers_block_type eq 'Regexp';
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request, @matches ) = @_;
				my @result;
				for ($request->query_raw) {
					@result = $code->(@matches);
				}
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif ($handler eq 'all') {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request, @matches_or_pos ) = @_;
				my @result = $code->($self,$request,\@matches_or_pos);
				return @result ? $result_handler->($self,@result) : ();
			});
		} else {
			croak "I dont know how to handle ".$handler."!";
		}

		#
		# apply role
		#

		Moo::Role->apply_role_to_package($target,$role) if $role;
	});
}

1;
