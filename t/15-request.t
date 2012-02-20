#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use DDG::Request;

BEGIN {

	my @t = (
		'   !bang test' => {
			query => 'bang test',
			wordcount_unmodified => 2,
			wordcount => 2,
			words_unmodified => [qw/ !bang test /],
			words => [qw/ bang test /],
		},
		'!bang  	  test' => {
			query => 'bang test',
			wordcount_unmodified => 2,
			wordcount => 2,
			words_unmodified => [qw/ !bang test /],
			words => [qw/ bang test /],
		},
		'other !bang test' => {
			query => 'other !bang test',
			wordcount_unmodified => 3,
			wordcount => 3,
			words_unmodified => [qw/ other !bang test /],
			words => [qw/ other bang test /],
			combined_lc_words_2 => ['other bang','bang test'],
		},
		'%"test %)()%!%§ +##+tesfsd' => {
			query => '%"test %)()%!%§ +##+tesfsd',
			wordcount_unmodified => 3,
			wordcount => 2,
			words_unmodified => ['%"test','%)()%!%§','+##+tesfsd'],
			words => [qw/ test tesfsd /],
			lc_words => [qw/ test tesfsd /],
			combined_lc_words_2 => ['test tesfsd'],
		},
		'test...test test...Test' => {
			query => 'test...test test...Test',
			wordcount_unmodified => 2,
			wordcount => 4,
			words_unmodified => ['test...test','test...Test'],
			words => [qw/ test test test Test /],
			lc_words => [qw/ test test test test /],
			combined_lc_words_2 => ['test test','test test','test test'],
		},
		'   %%test     %%%%%      %%%TeSFsd%%%  ' => {
			query => '%%test %%%%% %%%TeSFsd%%%',
			wordcount_unmodified => 3,
			wordcount => 2,
			words_unmodified => ['%%test','%%%%%','%%%TeSFsd%%%'],
			words => [qw/ test TeSFsd /],
			lc_words => [qw/ test tesfsd /],
		},
		'reverse bla' => {
			query => 'reverse bla',
			wordcount_unmodified => 2,
			wordcount => 2,
			words => [qw/ reverse bla /],
			lc_words => [qw/ reverse bla /],
		},
		'    !reverse bla   ' => {
			query => 'reverse bla',
			wordcount_unmodified => 2,
			wordcount => 2,
			words_unmodified => [qw/ !reverse bla /],
		},
		'    !REVerse BLA   ' => {
			query => 'REVerse BLA',
			wordcount_unmodified => 2,
			wordcount => 2,
			words_unmodified => [qw/ !REVerse BLA /],
			words => [qw/ REVerse BLA /],
			lc_words => [qw/ reverse bla /],
		},
	);

	while (@t) {
		my $query = shift @t;
		my %result = %{shift @t};
		my %args;
		%args = $result{args} if defined $result{args};
		my $req = DDG::Request->new({ query_unmodified => $query, %args });
		isa_ok($req,'DDG::Request');
		is($req->query_unmodified,$query,'Testing query_unmodified of "'.$query.'"');
		for (qw/ query wordcount text_wordcount /) {
			is($req->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
		for (qw/ words text_words lc_words lc_text_words /) {
			is_deeply($req->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
		for (qw/ combined_lc_words_2 /) {
			my $result_key = $_;
			my ( $param ) = $_ =~ m/_(\w)+$/;
			is_deeply($req->combined_lc_words($param),$result{$result_key},'Testing '.$result_key.' of "'.$query.'"') if defined $result{$result_key};
		}
	}
	
}

done_testing;
