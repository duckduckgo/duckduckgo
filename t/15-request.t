#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use DDG::Request;

BEGIN {

	my @t = (
		'   !bang test' => {
			query_unmodified => '   !bang test',
			query => 'bang test',
			query_lc => 'bang test',
			query_nowhitespace => 'bangtest',
			query_nowhitespace_nodash => 'bangtest',
			query_clean => 'bang test',
			wordcount => 2,
			query_parts => [qw( !bang test )],
			words => [qw( bang test )],
		},
		'!bang  	  test-test' => {
		},
		'other !bang test' => {
		},
		'%"test %)()%!%§ +##+tesfsd' => {
		},
		'test...test test...Test' => {
		},
		'   %%test     %%%%%      %%%TeSFsd%%%  ' => {
		},
		'reverse bla' => {
		},
		'    !reverse bla   ' => {
		},
		'    !REVerse BLA   ' => {
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
		for (qw/ query_unmodified query query_lc query_nowhitespace query_nowhitespace_nodash query_clean wordcount /) {
			is($req->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
		for (qw/ query_parts /) {
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
