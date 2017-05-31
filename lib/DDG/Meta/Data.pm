package DDG::Meta::Data;
# ABSTRACT: Metadata functions for instant answers

use JSON::XS qw'decode_json encode_json';
use Path::Class;
use File::ShareDir 'dist_file';
use LWP::UserAgent;
use File::Copy::Recursive 'pathmk';
use List::Util qw( all any );
use File::Copy;

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

# Only build metadata once.
unless(%ia_metadata){

    my $tmpdir = $ENV{METADATA_TMP_DIR} || '/var/tmp/ddg-metadata';

    my $mdir = "$tmpdir-$>";
    unless(-d $mdir){
        pathmk $mdir or die "Failed to mkdir $mdir: $!";
    }

    debug && warn "Processing metadata";

    my $f = "$mdir/metadata.json.bz2";
    my $tmp_bak = "$f.bak";
    my @timestamps = (stat $f)[8,9];
    if(-e $f){
        copy $f, $tmp_bak or die "Failed to copy $f to $tmp_bak: $!";;
    }
    utime @timestamps, $tmp_bak;
    my $restore_backup = sub {
        move $tmp_bak, $f or die "Failed to move backup $tmp_bak to $f: $!";
        utime @timestamps, $f;
    };

    unless($ENV{NO_METADATA_DOWNLOAD}){
        my $ua = LWP::UserAgent->new;
        $ua->timeout(5);
        $ua->default_header('Accept-Encoding' => scalar HTTP::Message::decodable());
        my $res = $ua->mirror('http://ddg-community.s3.amazonaws.com/metadata/repo_all.json.bz2', $f);
        unless($res->is_success || $res->code == 304){
            debug && warn "Failed to download metdata: " . $res->status_line . " .  Restoring backup from $tmp_bak";
            $restore_backup->();
        }
    }

    my $metadata;
    while(!$metadata){
        eval {
            # Decompress to command-line
            open my $fh, "bzip2 -dc $f |" or die "Failed to open file $f: $!";
            # slurp into a single string
            my $json = do { local $/;  <$fh> };
            $metadata = decode_json($json);
        }
        or do {
            if(-e $tmp_bak){
                debug && warn "Failed to process metadata $f: $@. Restoring backup from $tmp_bak";
                $restore_backup->();
            }
            else{
                die "Failed to to process metadata from $f: $@";
            }
        };
    }
    unlink $tmp_bak if -e $tmp_bak;

    # { "<id>": {
    #     "id": " "
    #     "signal" : " "
    #     ....
    # }

    IA: while (my ($id, $ia) = each %{ $metadata }) {

        # 20150502 (zt) Can't filter like this yet as some tests depend on non-live IA metadata
        #next unless $ia->{status} eq 'live';

        # warn if we run into a duplicate id.  These should be unique within *and*
        # across all IA types
        if( $ia_metadata{id}{$id} ){
            warn "Duplicate ID for IA with ID: $id";
        }

        # Perl modules aren't strictly required, e.g. Fatheads and Longtails
        # It's ok not to have every IA represented in the by_module view
        # We may need to update the parameter to _js_callback_name in the future
        if(my $perl_module = $ia->{perl_module}){
            #add new ia to ia_metadata{module}. Multiple ias per module possible
            push @{$ia_metadata{module}{$perl_module}}, $ia;
            $ia->{js_callback_name} = _js_callback_name($perl_module);
        }

        # Clean up/set some values
        $ia->{signal_from} ||= $ia->{id};

        #add new ia to ia_metadata{id}
        $ia_metadata{id}{$id} = $ia;
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

    my $m = $ia_metadata{$by}{$lookup};
    warn 'Returning IA ', p($m) if debug;
    return $m;
}

# filter_ias({ repo => 'goodies', dev_milestone => 'live'... })
# Lookups combine as an AND operation.
# Returns a list of IAs on `wantarray', otherwise an (id => ia) HASH ref.
#
# Each condition consists of a $key and $lookup.
# $lookup should be either a string, ARRAY ref, or CODE ref.
# If a string, then $lookup is compared with `eq'
# If a CODE ref, then $lookup is called with the IAs $key attribute and
# should return a boolean value.
# If an ARRAY ref, then the above two rules are used with each element, the
# IA only needs to satisfy one.
sub filter_ias {
    my $lookups = $_[1];
    my %ias = %{by_id()};
    my %lookups = %$lookups;
    my @by = keys %lookups;
    # Ensure lookups are of the form (by => [lookup...])
    map {
        my $cond = $lookups{$_};
        $lookups{$_} = [$cond] unless ref $cond eq 'ARRAY';
    } @by;
    while (my ($id, $ia) = each %ias) {
        delete $ias{$id} unless all {
            my ($by, $lookup) = ($_, $lookups{$_});
            any {
                ref $_ eq 'CODE' ? $_->($ia->{$by}) : $_ eq $ia->{$by};
            } @$lookup;
        } @by;
    }
    return wantarray ? (values %ias) : \%ias;
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
