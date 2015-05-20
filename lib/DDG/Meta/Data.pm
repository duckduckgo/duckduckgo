package DDG::Meta::Data;
# ABSTRACT: Metadata functions for instant answers

use JSON::XS qw'decode_json encode_json';
use Path::Class;
use File::ShareDir 'dist_file';
use IO::All;
use Clone 'clone';

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

    # Load IA metadata files. Not all types are required during development.
    my %metadata_files;
    for my $iat (@ia_types){
        my $bundle = "DDG::${iat}Bundle::OpenSourceDuckDuckGo";
        eval "require $bundle";
        my $f = eval{ dist_file("DDG-${iat}Bundle-OpenSourceDuckDuckGo", lc $iat . '/meta/metadata.json') }
            or (debug && warn $@);
        $metadata_files{$iat} = $f if $f;
    }

    unless(%metadata_files){
        warn("[Error] No Instant Answer bundles installed. If you are developing an Instant Answer, please\n",
             "install one or more of the following (via `duckpan` or `cpanm --mirror http://duckpan.org`),\n",
         "including the type with which you are working:\n\n\t",
        join("\n\t", map{ "DDG::${_}Bundle::OpenSourceDuckDuckGo" } @ia_types), "\n"); # and exit 1;
    }

    FILE: while (my ($type, $filename) = each %metadata_files) {
        warn "Processing IA type: $type with file $filename" if debug;

        # One metadata file for each repo with the following format
        # { "<IA name>": {
        #     "id": " " 
        #     "signal" : " "
        #     ....
        # }
        my $file_data = decode_json(io($filename)->all);

        # check for decode_json_file error, returns undef
        die "reading metadata file failed ... $filename" unless $file_data;

        IA: while (my ($id, $module_data) = each %{ $file_data }) {

            # 20150502 (zt) Can't filter like this yet as some tests depend on non-live IA metadata
            #next unless $module_data->{status} eq 'live';

            # check for bad metadata.  We need a perl_module for the by_module key
            if($module_data->{perl_module} !~ /DDG::.+::.+/){
                warn "Invalid perl_module for IA $id: $module_data->{perl_module} in $filename...skipping" if $module_data->{status} eq 'live';
                next IA;
            }

            # generic IsAwesome goodie metadata since these are always the same
            if($module_data->{perl_module} =~ /IsAwesome/){
                next IA if $ia_metadata{module}{'DDG::Goodie::IsAwesome'};
                $module_data->{id} = 'is_awesome';
                $module_data->{perl_module} = 'DDG::Goodie::IsAwesome'
            }

            # warn if we run into a duplicate id.  These should be unique within *and*
            # across all IA types
            if( $ia_metadata{id}{$id} ){
                warn "Duplicate ID for IA with ID: $id";
            }

            my $perl_module = $module_data->{perl_module};

            # Clean up/set some values
            $module_data->{signal_from} ||= $module_data->{id};
            $module_data->{js_callback_name} = _js_callback_name($perl_module);

            #add new ia to ia_metadata{id}
            $ia_metadata{id}{$id} = $module_data;
            #add new ia to ia_metadata{module}. Multiple ias per module possible
            push @{$ia_metadata{module}{$perl_module}}, $module_data;
        }
    }
}

my %applied;

sub apply_keywords {
    my ($self, $target) = @_;

    return if $applied{$target};    

    my $ias;
    unless($ias = $self->get_ia(module => $target)){
        warn "No metadata found for $target" if debug;
        return;
    }
    # If only one id this will be false. Only a few IAs have
    # multiple ids per module, e.g. CheatSheets
    my $id_required = @{$ias} - 1;

    my $s = Package::Stash->new($target);

    # Will return metadata by id from the current subset of the IA's metadata
    my $dynamic_meta = sub {
        my $id = $_[0];
        unless($id){
            die "No id provided to dynamic instant answer";
        }
        my @m = grep {$_->{id} eq $id} @$ias;
        unless(@m == 1){
            die "Failed to select metadata with id $id";
        }
        return $m[0];
    };

    # Check for id_required *outside* of the subs so we don't incur the
    # slight performance penalty across the board. Remember that these
    # are method calls and that $_[0] is self
    while(my ($k, $v) = each %{$ias->[0]}){ # must have at least one set of metadata
        $s->add_symbol("&$k", $id_required ? 
            sub {
                my $m = $dynamic_meta->($_[1]);
                return $m->{$k};
            }
            :
            sub { $v }
        );
    }
    $s->add_symbol('&metadata', $id_required ? 
        sub {
            my $m = $dynamic_meta->($_[1]);
            return clone($m);
        }
        :
        sub { clone($ias->[0]) }
    );
}

sub get_ia {
    my ($self, $by, $lookup) = @_;
    warn 'Get IA obj lookup params: ', p($lookup) if debug;
    
    $lookup =~ s/^DDG::Goodie::IsAwesome\K::.+$//;

    # make a copy of the hash; doesn't need deep cloning atm
    my $m = $ia_metadata{$by}{$lookup};
    warn 'Returning IA ', p($m) if debug;
    return clone($m);
}

sub get_js {
    my ($self, $id) = @_;

    my $metaj = eval { encode_json($self->get_ia(id => $id)) } or warn "Failed to encode metdata to json: $@";
    return qq(DDH.$id = DDH.$id || {};\nDDH.$id.meta = $metaj;); 
}

# return a hash of IA objects by id
sub by_id {
    return clone($ia_metadata{id});
}

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
