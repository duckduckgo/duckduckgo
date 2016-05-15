package DDG::Meta::RequestHandler;
# ABSTRACT: Functions for a request handler

use strict;
use warnings;
use Carp;
use Package::Stash;
use DDG::Location;
use DDG::Language;
require Moo::Role;

=head1 DESCRIPTION

This meta class can install the required B<handle_request_matches> function
required by the L<DDG::IsGoodie> and the L<DDG::IsSpice> role.

It installs the keyword L</handle>, which installs this function on its call.

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

my @request_hash_attributes = qw(

	matcher

);

my $default_handler = 'query_raw';

=method apply_keywords

This function installs the L</handle> keyword. It requires for this the target
package name, a result handler for handling the results of the plugins and
optional a role which is applied after installing the keyword. This function
is used in L<DDG::Meta> as part of all the meta for L<DDG::Goodie> and
L<DDG::Spice>.

=cut

my %applied;

sub apply_keywords {
	my ( $class, $target, $result_handler, $role ) = @_;

	return if exists $applied{$target};
	$applied{$target} = undef;
	
	my $stash = Package::Stash->new($target);

	$class->reset_request_symbols($stash);

=keyword handle

This function takes the keyword for the to handle attribute of the request as
first parameter and a coderef of the actual handler.

An example can look like:

  handle remainder => sub { lc($_) };

You must define triggers before you are allowed to define a handler, cause
specific features are only available for specific L<DDG::Block>
implementations.

The choosen keyword defines which data can be found in B<$_> or B<@_>
depending on the kind of data. If the requested attribute is an array then you
get B<query_raw> on B<$_> and the array of the attribute on B<@_>.

If you dont give any keyword and just give a coderef, then B<query_raw> is
taken as keyword for the attribute.

L<DDG::Block::Regexp> based plugins can use B<matches> to get the matches of
the regexp as parameter on B<@_>.

L<DDG::Block::Words> can use B<remainder> and B<remainder_lc> which gives back
the parts of the query which are not hit by the trigger of the plugin. It is
the most used handler.

The following keywords can be used by all plugins, cause they are based on the
L<DDG::Request> itself:

- query_raw
- query_nowhitespace
- query_nowhitespace_nodash
- query
- query_lc
- query_clean
- wordcount
- words (array)
- query_parts (array)
- query_raw_parts (array)

To access the L<DDG::Request> itself, you can directly access the variable
B<$req> which is set to the current L<DDG::Request> for the call to the
coderef of the handler.

You also get B<$loc> and B<$lang> which are always L<DDG::Location> and
L<DDG::Language> objects, even if the L<DDG::Request> had none. Given this
case, then all functions give back empty values of the objects. This way you
can directly work with those variable without getting error messages for
accessing functions which are not there. To find out if there is a location
or language at all you can use B<$has_loc> and B<$has_lang>.

=cut

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
				$class->request_symbols($stash,$request);
				my @result;
				my $default = $request->$handler;
				for ($default) {
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
				my $default = $request->$default_handler;
				for ($default) {
					@result = $code->(@{$request->$handler});
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self,@result) : ();
			});
		} elsif (grep { $_ eq $handler } @request_hash_attributes) {
			$stash->add_symbol('&handle_request_matches',sub {
				my ( $self, $request ) = @_;
				$class->request_symbols($stash,$request);
				my @result;
				my $default = $request->$default_handler;
				for ($default) {
					my $match = $self->matcher->full_match($_);
					@result = $match ? $code->($match) : ();
				}
				$class->reset_request_symbols($stash);
				return @result ? $result_handler->($self,@result) : ();
			});
		# LEGACY vvvv (got replaced with $req feature)
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
		#        ^^^^
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
				my $default = $request->query_raw;
				for ($default) {
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

=method request_symbols

This function uses a given L<Package::Stash> and L<DDG::Request> to implement
the B<$loc>, B<$has_loc>, B<$lang> and B<$has_lang> variables on the package
of the L<Package::Stash>. It will automatically called by the installed
handler, you never need to call it.

=cut

sub request_symbols {
	my ( $class, $stash, $request ) = @_;
	$stash->add_symbol('$req',\$request);

	$stash->add_symbol('$has_loc',$request->has_location);
	if ($request->has_location) {
		$stash->add_symbol('$loc',\$request->location);
	} else {
		$stash->add_symbol('$loc',\DDG::Location->new);
	}

	$stash->add_symbol('$has_lang',$request->has_language);
	if ($request->has_language) {
		$stash->add_symbol('$lang',\$request->language);
	} else {
		$stash->add_symbol('$lang',\DDG::Language->new);
	}

	# $stash->add_symbol('$has_reg',$request->has_region);
	# if ($request->has_region) {
	# 	$stash->add_symbol('$reg',\$request->region);
	# } else {
	# 	$stash->add_symbol('$reg','');
	# }

}

=method reset_request_symbols

This function uses a given L<Package::Stash> and unsets B<$loc>, B<$has_loc>,
B<$lang> and B<$has_lang> again. It will automatically called by the installed
handler, you never need to call it.

=cut

sub reset_request_symbols {
	my ( $class, $stash ) = @_;
	$stash->add_symbol('$req',undef);

	$stash->add_symbol('$has_loc',undef);
	$stash->add_symbol('$loc',undef);

	$stash->add_symbol('$has_lang',undef);
	$stash->add_symbol('$lang',undef);

	# $stash->add_symbol('$has_reg',undef);
	# $stash->add_symbol('$reg',undef);
}

1;
