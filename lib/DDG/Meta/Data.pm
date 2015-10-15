package DDG::Meta::Data;
# ABSTRACT: Metadata functions for instant answers

use JSON::XS qw'decode_json encode_json';
use Path::Class;
use File::ShareDir 'dist_file';
use LWP::UserAgent;
use PerlIO::gzip;
use File::Copy::Recursive 'pathmk';

use strict;

sub debug { 0 }
use if debug, 'Data::Printer';

no warnings 'uninitialized';

# $ia_metadata => {
#    id => ...
#    module => ...
#    sharedir => ...
# }
my %ia_metadata;

# Only build metadata once. Not in BUILD so we can call apply_keywords directly
unless(%ia_metadata){

    my $tmpdir = $ENV{METADATA_TMP_DIR} || '/var/tmp/ddg-metadata';

    my $mdir = "$tmpdir-$>";
    unless(-d $mdir){
        pathmk $mdir or die "Failed to mkdir $mdir: $!";
    }

    debug && warn "Processing metadata";

    my $f = "$mdir/metadata.json";
    unless($ENV{NO_METADATA_DOWNLOAD}){
        my $ua = LWP::UserAgent->new;
        $ua->timeout(5);
        $ua->default_header('Accept-Encoding' => scalar HTTP::Message::decodable());
        my $res = $ua->mirror('https://duck.co/ia/repo/all/json', $f);
        unless($res->is_success || $res->code == 304){
            debug && warn "Failed to download metdata: " . $res->status_line;
        }
    }

    open my $fh, -B $f ? '<:gzip' : '<', $f or die "Failed to open file $f: $!";
    my $metadata = decode_json( do { local $/;  <$fh> } );
    close $fh;

    # One metadata file for each repo with the following format
    # { "<IA name>": {
    #     "id": " "
    #     "signal" : " "
    #     ....
    # }

    IA: while (my ($id, $ia) = each %{ $metadata }) {

        # 20150502 (zt) Can't filter like this yet as some tests depend on non-live IA metadata
        #next unless $ia->{status} eq 'live';

        # check for bad metadata.  We need a perl_module for the by_module key
        if($ia->{perl_module} !~ /DDG::.+::.+/){
            warn "Invalid perl_module for IA $id: $ia->{perl_module} in metadata...skipping" if $ia->{status} eq 'live';
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
        if($ia->{repo} eq 'fathead'){
            my $source = $ia->{src_id};
            # by source number for fatheads
            $ia_metadata{fathead_source}{$source} = $ia;
            # by language for multi language wiki sources
            # check that language is set since most fatheads don't have a language
            if( my $lang = $ia->{src_options}{language}){
                # By default use current source
                my $want_src = $source;
                if(exists $ia_metadata{fathead_lang}{$lang}){
                    my $prev_ia = $ia_metadata{fathead_source}{$ia_metadata{fathead_lang}{$lang}};
                    # Skip setting lang to source if existing src_id is lower
                    $want_src = 0 if $prev_ia->{src_id} < $ia->{src_id};
                }
                $ia_metadata{fathead_lang}{$lang} = $want_src if $want_src;
            }
            my $min_length = $ia->{src_options}{min_abstract_length};
            $ia_metadata{fathead_min_length}{$source} = $min_length if $min_length;
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
