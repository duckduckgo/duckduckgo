package DDG::Meta::Data;
# ABSTRACT: Metadata functions for instant answers

use JSON::XS qw'decode_json encode_json';
use Path::Class;
use File::ShareDir 'dist_file';
use IO::All;
use LWP::Simple;

use strict;

sub debug { 0 }
use if debug, 'Data::Printer';

no warnings 'uninitialized';

# $ia_metadata => {
#    id => { ... }
#    module => { ... }
#    sharedir => { ... }
# }
my %ia_metadata;

# Only build metadata once. Not in BUILD so we can call apply_keywords directly
unless(%ia_metadata){

    my @ia_types = qw(Spice Goodie Longtail Fathead);

    my $tmpdir = io->tmpdir;
    unless($tmpdir){
       die 'No system temp directory found';
    }

    my $mdir = "$tmpdir/ddg-$>";
    unless(-d $mdir){
        mkdir $mdir or die "Failed to mkdir $mdir: $!";
    }

    # Load IA metadata. Not all types are required during development.
    for my $iat (@ia_types){
        debug && warn "Processing IA type: $iat";

        my $json_endpt = lc $iat;
        $json_endpt =~ s/goodie/goodies/;

        # Prefer freshly downloaded metadata and fall back to metadata
        # bundled with installed IA repos
        my $f = "$mdir/$iat.json";
        my $c = $ENV{NO_METADATA_DOWNLOAD} ? 0 : mirror("https://duck.co/ia/repo/$json_endpt/json", $f);
        my $json;
        if($c == RC_OK || $c == RC_NOT_MODIFIED){
            $json = io($f)->slurp; 
        }
        else {
            debug && warn "Failed to download metdata for $iat: $c";
            if(-f $f){
                $json = io($f)->all;
            }
            else{
               warn "Failed to download metadata for $iat and no local file $f";
            }
        }

        next unless $json;
        my $metadata = eval{ decode_json($json); } or warn "Failed to decode_json: $@";
        next unless $metadata;

        # One metadata file for each repo with the following format
        # { "<IA name>": {
        #     "id": " " 
        #     "signal" : " "
        #     ....
        # }

        my $is_fathead = 1 if $iat eq 'Fathead';

        IA: while (my ($id, $ia) = each %{ $metadata }) {

            # 20150502 (zt) Can't filter like this yet as some tests depend on non-live IA metadata
            #next unless $ia->{status} eq 'live';

            # check for bad metadata.  We need a perl_module for the by_module key
            if($ia->{perl_module} !~ /DDG::.+::.+/){
                warn "Invalid perl_module for IA $id: $ia->{perl_module} in $iat metadata...skipping" if $ia->{status} eq 'live';
                next IA;
            }

            # generic IsAwesome goodie metadata since these are always the same
            if($ia->{perl_module} =~ /IsAwesome/){
                next IA if $ia_metadata{module}{'DDG::Goodie::IsAwesome'};
                $ia->{id} = 'is_awesome';
                $ia->{perl_module} = 'DDG::Goodie::IsAwesome'
            }

            # warn if we run into a duplicate id.  These should be unique within *and*
            # across all IA types
            if( $ia_metadata{id}{$id} ){
                warn "Duplicate ID for IA with ID: $id";
            }

            my $perl_module = $ia->{perl_module};

            # Clean up/set some values
            $ia->{signal_from} ||= $ia->{id};
            $ia->{js_callback_name} = _js_callback_name($perl_module);

            #add new ia to ia_metadata{id}
            $ia_metadata{id}{$id} = $ia;
            #add new ia to ia_metadata{module}. Multiple ias per module possible
            push @{$ia_metadata{module}{$perl_module}}, $ia;
            # by language for multilang wiki
            if($is_fathead){
                my $source = $ia->{src_id};
                # by source number for fatheads
                $ia_metadata{fathead_source}{$source} = $ia;
                # by language for multi language wiki sources
                # check that language is set since most fatheads don't have a language
                if( my $lang = $ia->{src_options}{language}){
                    $ia_metadata{fathead_lang}{$lang} = $source;
                }
                my $min_length = $ia->{src_options}{min_abstract_length};
                $ia_metadata{fathead_min_length}{$source} = $min_length if $min_length;
            }
        }
    }

    unless(%ia_metadata){
        warn "[Error] No Instant Answer metadata loaded. Metadata will be downloaded\n",
             "automatically and stored in $mdir if a network connection can be made\n",
			 "to https://duck.co.\n";
    }
}

sub get_ia {
    my ($self, $by, $lookup) = @_;
    warn 'Get IA obj lookup params: ', p($lookup) if debug;
    
    $lookup =~ s/^DDG::Goodie::IsAwesome\K::.+$//;

    my $m = $ia_metadata{$by}{$lookup};
    warn 'Returning IA ', p($m) if debug;
    return $m;
}

sub get_js {
    my ($self, $by, $lookup) = @_;
    return unless $by =~ /id|source/;
    my $ia = $self->get_ia($by => $lookup);
    return unless $ia;

    my $id = $ia->{id};
    my $metaj = eval { JSON::XS->new->ascii->encode($ia) } || return;
    return qq(DDH.$id=DDH.$id||{};DDH.$id.meta=$metaj;); 
}

# return a hash of IA objects by id
sub by_id { $ia_metadata{id} }

# return a hash of IA metadata for fatheads
sub fathead_by_source { $ia_metadata{fathead_source} }

# return hash if IA metadata by language
sub fathead_by_lang { $ia_metadata{fathead_lang} }

# fathead min lengths
sub fathead_by_length { $ia_metadata{fathead_min_length} }

# Internal function.
sub _js_callback_name {
    my $name = shift;
    my $fn;
    if(($fn) = $name =~ /^DDG::\w+::(\w.+)$/o){
        $fn =~ s/::/_/og;
        $fn =~ s/([a-z])([A-Z])/$1_$2/og;
        $fn = lc $fn;
    }
    return $fn;
}

1;
