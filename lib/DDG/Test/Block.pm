package DDG::Test::Block;
# ABSTRACT: Adds a function to easily test L<DDG::Block>.

use strict;
use warnings;
use Carp;
use Test::More;
use Class::Load ':all';
use Set::Scalar;
use List::AllUtils qw/pairkeys/;
use DDG::Request;
use DDG::Block::Words;
use DDG::Block::Regexp;
use DDG::Test::Location;
use DDG::Test::Language;
use Package::Stash;

sub import {
	my ( $class, %params ) = @_;
	my $target = caller;

	my $stash = Package::Stash->new($target);

=keyword block_test

This exported function is used by L<DDG::Test::Spice> and L<DDG::Test::Goodie>
to get easier access to test a plugin with a block. Please see there for more
informations.

=cut

	$stash->add_symbol('&block_test',sub {
		my ($result_callback, $plugins, @queries_targets) = @_;
        my @queries = pairkeys @queries_targets;
		my @regexp; my @words;
		foreach my $plugin (@plugins) {
			load_class($plugin);
			if ($plugin->triggers_block_type eq 'Words') {
				push @words, $plugin;
			} elsif ($plugin->triggers_block_type eq 'Regexp') {
				push @regexp, $plugin;
			} else {
				croak "Unknown plugin type";
			}
		}
		my $words_block = @words ? DDG::Block::Words->new( plugins => [@words]) : undef;
		my $regexp_block = @regexp ? DDG::Block::Regexp->new( plugins => [@regexp]) : undef;
		while (@queries_targets) {
			my $query = shift @queries_targets;
			my $request;
			if (ref $query eq 'DDG::Request') {
				$request = $query;
				$query = $request->query_raw;
			} else {
				$request = DDG::Request->new(
					query_raw => $query,
					location => test_location('us'),
					language => test_language('us'),
				);
			}
			my $target = shift @queries_targets;
			my $answer = undef;
			( $answer ) = $words_block->request($request) if $words_block;
			( $answer ) = $regexp_block->request($request) if $regexp_block && !$answer;
			if ( defined $target ) {
				for ($answer) {
					$result_callback->($query,$answer,$target);
				}
			} else {
				is($answer,$target,'Checking for not matching on '.$query);
			}
		}
        $class->require_tests_for_example_queries($plugins, \@queries);
	});

}

sub require_tests_for_example_queries {
    my ($class, $plugins, $tested_queries) = @_;

    # NOTE: This only requires tests for examples queries in the first plugin
    my $meta = $plugins->[0]->get_meta_information;
    my @example_queries = (
        @{ $meta->{primary_example_queries}   },
        @{ $meta->{secondary_example_queries} },
    );

    # set difference
    my $difference = Set::Scalar->new(@example_queries) - 
                     Set::Scalar->new(@$tested_queries);

    my $note = "\n  Tests for the following queries are missing:\n    " .
        join("\n    ", $difference->elements);

    # this env variable is only true when running tests in
    # t/require_example_queries/goodie.t and
    # t/require_example_queries/spice.t
    if ($ENV{DDG_REQUIRE_EXAMPLE_QUERIES_TEST}) {
        die $note unless $difference->size == 0;
    }
    else {
        ok( $difference->size == 0, "Tests for example queries exist") ||
            note $note;
    }
}

1;
