package DDG::Meta::Data;
# ABSTRACT: Metadata functions for instant answers

use JSON::XS qw'decode_json encode_json';
use Path::Class;
use File::ShareDir 'dist_file';
use IO::All;
use Clone 'clone';
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

	my $home = (getpwuid $>)[7];
	unless($home){
	   die "No home directory found uid $>: $home";
	}

	my $mdir = "$home/.ddg";
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
        }
    }

    unless(%ia_metadata){
        warn("[Error] No Instant Answer metadata loaded. Metadata will be downloaded\n",
             "automatically if a network connection can be made to https://duck.co.\n",
             "Alternatively, if you are developing an Instant Answer, you can install\n",
             "one or more of the following (via `duckpan` or `cpanm --mirror http://duckpan.org`),\n",
             "including the type with which you are working:\n\n\t",
        join("\n\t", map{ "DDG::${_}Bundle::OpenSourceDuckDuckGo" } @ia_types), "\n"); # and exit 1;
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

    my $metaj = eval { encode_json($self->get_ia(id => $id)) } || qq|{"encode_json error":"$@"}|;
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
