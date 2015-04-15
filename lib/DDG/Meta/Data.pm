package DDG::Meta::Data;
use Moo;
use DDG::SpiceBundle::OpenSourceDuckDuckGo; 
use DDG::GoodieBundle::OpenSourceDuckDuckGo; 
use DDG::LongtailBundle::OpenSourceDuckDuckGo; 
use DDG::FatheadBundle::OpenSourceDuckDuckGo; 
use JSON::XS 'decode_json';
use Path::Class;
use File::ShareDir 'dist_file';
use IO::All;

sub debug { 0 }
use if debug, 'Data::Printer';

no warnings 'uninitialized';

# $ia_metadata => {
#    id => { ... }
#    module => { ... }
#    sharedir => { ... }
# }
my %ia_metadata;

my @ia_types = qw(Spice Goodie Longtail Fathead);

my %metadata_files = map { $_ => dist_file("DDG-${_}Bundle-OpenSourceDuckDuckGo", lc $_ . '/meta/metadata.json') } @ia_types;

# Only build metadata once. Not in BUILD so we can call apply_keywords directly
unless(%ia_metadata){

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
        warn "reading metadata file failed ... $filename" unless $file_data;

        IA: while (my ($id, $module_data) = each %{ $file_data }) {

            # check for bad metadata.  We need a perl_module for the by_module key
            if($module_data->{perl_module} !~ /DDG::.+::.+/){
                warn "Something wrong with perl_module for IA $id perl_module: $module_data->{perl_module} in $filename ...  Not fatal but the IA won't show";
                next IA;
            }

            # generic IsAwesome goodie metadata since these are always the same
            if($module_data->{perl_module} =~ /IsAwesome/){
                next IA if $ia_metadata{module}{'DDG::Goodie::IsAwesome'};
                $module_data->{id} = 'is_awesome';
                $module_data->{perl_module} = 'DDG::Goodie::IsAwesome'
            }

            # warn if we run into a duplicate id.  These should be unique
            if( $ia_metadata{id}{$id} ){
                warn "Duplicate ID for IA with ID: $id";
            }

            my $perl_module = $module_data->{perl_module};

            # create a new ia
            my $ia = {
                id => $module_data->{id},
                signal_from => $module_data->{signal_from} || $module_data->{id},
                status => $module_data->{status},
                example_query => $module_data->{example_query},
                name => $module_data->{name},
                description => $module_data->{description},
                repo => $module_data->{repo},
                tab => $module_data->{tab},
                perl_module => $perl_module,
                topic => $module_data->{topic},
                js_callback_name => $self->js_callback_name($perl_module)
            };

            #add new ia to ia_metadata{id}
            $ia_metadata{id}{$id} = $ia;
            #add new ia to ia_metadata{module}
            $ia_metadata{module}{$perl_module} = $ia;
        }
    }
}

my %applied;

sub apply_keywords {
    my ($self, $target) = @_;

    return if $applied{$target};    

    my $ia;
    unless($ia = $self->get_ia(module => $target)){
        warn "No metadata found for $target"; 
        return;
    }

    my $s = Package::Stash->new($target);

    while(my ($k, $v) = each %$ia){
        $s->add_symbol("&$k", sub { $v });
    }
    $s->add_symbol('&metadata', sub { return {%$ia} });
}

sub get_ia {
    my ($self, $by, $lookup) = @_;
    warn 'Get IA obj lookup params: ', p($lookup) if debug;
    
    $lookup =~ s/^DDG::Goodie::IsAwesome\K::.+$//;

    # make a copy of the hash; doesn't need deep cloning atm
    my %ia = %{$ia_metadata{$by}{$lookup}};
    warn 'Returning IA ', p(%ia) if debug;
    return \%ia;
}

# return a hash of IA objects by id
sub by_id {
    my %h = %{$ia_metadata{id}};
    return \%h;
}

sub js_callback_name {                                                                                                                                                                                                                                                                                             
    my ($self, $name) = @_;
    my $fn;
    if(($fn) = $name =~ /^DDG::\w+::(\w.+)$/o){
        $fn =~ s/::/_/og;
        $fn =~ s/([a-z])([A-Z])/$1_$2/og;
        $fn = lc $fn;
    }
    return $fn;
}

1;
