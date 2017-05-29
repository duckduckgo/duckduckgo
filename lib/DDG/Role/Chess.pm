package DDG::GoodieRole::Chess;
# ABSTRACT: Helper function to parse a FEN string and draw a chessboard. 
# We could in principle use Chess::PGN::EPD, but that module does not provide
# the HTML output, so we just implement what we need and don't add a dependecny.

use strict;
use Scalar::Util qw(looks_like_number);
use Moo::Role;

# Parse the FEN string into an array of length 64.
sub parse_position {
    my ($i) = 0;
    my ($position) = @_;
    $position =~ s/^\s+|\s+$//g;
    my (@cases) = ();
    for (my $char = 0 ; $char < length($position) ; $char++ ) {
        my $fenchar = substr($position, $char, 1);
        if ($fenchar eq ' ') {
            return @cases;
        }
        if (looks_like_number($fenchar)) {
            for ($i = 0; $i < $fenchar; $i++){
                push(@cases, 'e');
            }
        }
        elsif ($fenchar ne '/') {
            push(@cases, $fenchar);
        }
    }
    return @cases;
}

# Generate a chessboard as a HTML table.
sub draw_chessboard_html {
    my (@position) = @_;
    my ($i) = 0;
    my ($j) = 0;
    my ($counter) = 0;
    my (@arr) = ("A".."Z");
    my (%class_dict) = (
        'r' => 'black rook',
        'n' => 'black knight',
        'b' => 'black bishop',
        'q' => 'black queen',
        'k' => 'black king',
        'p' => 'black pawn',
        'e' => 'empty',
        'R' => 'white rook',
        'N' => 'white knight',
        'B' => 'white bishop',
        'Q' => 'white queen',
        'K' => 'white king',
        'P' => 'white pawn',
    );
    
    my (%unicode_dict) = (
        'r' => '&#9820;',
        'n' => '&#9822;',
        'b' => '&#9821;',
        'q' => '&#9819;',
        'k' => '&#9818;',
        'p' => '&#9823;',
        'e' => '',
        'R' => '&#9814;',
        'N' => '&#9816;',
        'B' => '&#9815;',
        'Q' => '&#9813;',
        'K' => '&#9812;',
        'P' => '&#9817;',
        );
    
    my ($html_chessboard) = '<div class="zci--fenviewer"><table class="chess_board" cellpadding="0" cellspacing="0">';
    for ($i = 0; $i < 8; $i++){
        # Rows
        $html_chessboard .= '<tr>';
        for ($j = 0; $j < 8; $j++){
            # Columns
            $html_chessboard .= '<td id="'.$arr[$j].(8-$i).'">';
            $html_chessboard .= '<span class="'.$class_dict{$position[$counter]};
            $html_chessboard .= '">'.$unicode_dict{$position[$counter]}.'</span>';
            $html_chessboard .= '</td>';
            $counter++;
        }
        $html_chessboard .= '</tr>';
    }
    $html_chessboard .= '</table></div>';
    return $html_chessboard;
}

# Generate a chessboard in ASCII, with the same format as
# 'text output from Chess::PGN::EPD
sub draw_chessboard_ascii {
    my (@position) = @_;
    my ($i) = 0;
    my ($j) = 0;
    my ($counter) = 0;
    my ($ascii_chessboard) = "";
    for ($i = 0; $i < 8; $i++){
        # Rows
        for ($j = 0; $j < 8; $j++){
            # Columns
            if ($position[$counter] ne 'e') {
                # Occupied square
                $ascii_chessboard .= $position[$counter];
            }
            elsif ($j % 2 != $i % 2) {
                # Black square
                $ascii_chessboard .= '-';
            }
            else {
                # White square
                $ascii_chessboard .= ' ';
            }
            $counter++;
        }
        if($counter < 63) {
            $ascii_chessboard .= "\n";
        }
    }
    return $ascii_chessboard;
};

1;