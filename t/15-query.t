#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use DDG::Query;

BEGIN {

	my @t = (
		'   !bang test' => {
			query => 'bang test',
			wordcount => 2,
			text_wordcount => 2,
			words => [qw/ !bang test /],
			text_words => [qw/ bang test /],
		},
		'!bang  	  test' => {
			query => 'bang test',
			wordcount => 2,
			text_wordcount => 2,
			words => [qw/ !bang test /],
			text_words => [qw/ bang test /],
		},
		'other !bang test' => {
			query => 'other !bang test',
			wordcount => 3,
			text_wordcount => 3,
			words => [qw/ other !bang test /],
			text_words => [qw/ other bang test /],
		},
		'%"test %)()%!%§ +##+tesfsd' => {
			query => '%"test %)()%!%§ +##+tesfsd',
			wordcount => 3,
			text_wordcount => 2,
			words => ['%"test','%)()%!%§','+##+tesfsd'],
			lc_words => ['%"test','%)()%!%§','+##+tesfsd'],
			text_words => [qw/ test tesfsd /],
			text_lc_words => [qw/ test tesfsd /],
		},
		'reverse bla' => {
			query => 'reverse bla',
			wordcount => 2,
			text_wordcount => 2,
			words => [qw/ reverse bla /],
			text_words => [qw/ reverse bla /],
		},
		'    !reverse bla   ' => {
			query => 'reverse bla',
			wordcount => 2,
			text_wordcount => 2,
			words => [qw/ !reverse bla /],
			text_words => [qw/ reverse bla /],
		},
		'    !REVerse BLA   ' => {
			query => 'REVerse BLA',
			wordcount => 2,
			text_wordcount => 2,
			words => [qw/ !REVerse BLA /],
			text_words => [qw/ REVerse BLA /],
			lc_words => [qw/ !reverse bla /],
			text_lc_words => [qw/ reverse bla /],
		},
	);

	while (@t) {
		my $query = shift @t;
		my %result = %{shift @t};
		my %args;
		%args = $result{args} if defined $result{args};
		my $q = DDG::Query->new({ query_unmodified => $query, %args });
		isa_ok($q,'DDG::Query');
		is($q->query_unmodified,$query,'Testing query_unmodified of "'.$query.'"');
		for (qw/ query wordcount text_wordcount /) {
			is($q->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
		for (qw/ words text_words lc_words lc_text_words /) {
			is_deeply($q->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
	}
	
}

done_testing;
