package DDG::Meta::RequestHandler;
# ABSTRACT: Functions for a request handler

use strict;
use warnings;
use Carp;
use Package::Stash;
require Moo::Role;

=head1 DESCRIPTION



=cut

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

	$class->reset_request_symbols($stash);

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

=keyword handle_request_matches

This package installs the function which is required to handle a request for a
block. It will get fired when the triggers are matching.

...

=cut

		if (grep { $_ eq $handler } @request_scalar_attributes) {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				$class->request_symbols($stash,$request);
				my @result;
				for ($request->$handler) {
					@result = $code->($_);
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif (grep { $_ eq $handler } @request_array_attributes) {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				$class->request_symbols($stash,$request);
				my @result;
				for ($request->$default_handler) {
					@result = $code->(@{$request->$handler});
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif ($handler eq 'request') {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				$class->request_symbols($stash,$request);
				my @result;
				for ($request) {
					@result = $code->($_);
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif ($handler eq 'remainder' || $handler eq 'remainder_lc') {
			croak "You must be using words matching for remainder handler" unless $target->triggers_block_type eq 'Words';
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request, $from_pos, $to_pos ) = @_;
				$class->request_symbols($stash,$request);
				my $remainder = $request->generate_remainder($from_pos,$to_pos);
				my @result;
				for ($handler eq 'remainder' ? $remainder : lc($remainder)) {
					@result = $code->($_);
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self, @result) : ();
			});
		} elsif ($handler eq 'matches') {
			croak "You must be using regexps matching for matches handler" unless $target->triggers_block_type eq 'Regexp';
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request, @matches ) = @_;
				$class->request_symbols($stash,$request);
				my @result;
				for ($request->query_raw) {
					@result = $code->(@matches);
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif ($handler eq 'all') {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request, @matches_or_pos ) = @_;
				$class->request_symbols($stash,$request);
				my @result = $code->($self,$request,\@matches_or_pos);
				$class->reset_request_symbols($stash);
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

sub request_symbols {
	my ( $class, $stash, $request ) = @_;
	$stash->add_symbol('$req',\$request);
	$stash->add_symbol('$loc',\$request->location) if $request->has_location;
	$stash->add_symbol('$lang',\$request->language) if $request->has_language;
}

sub reset_request_symbols {
	my ( $class, $stash ) = @_;
	$stash->add_symbol('$req',undef);
	$stash->add_symbol('$loc',undef);
	$stash->add_symbol('$lang',undef);
}

1;
