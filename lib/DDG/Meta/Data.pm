package DDG::Meta::Data;
use Package::Stash;
use DDG::Util::Database qw( decode_json_file );
use Path::Class;

sub debug { 0 }
use if debug, 'Data::Printer';

no warnings 'uninitialized';

# perl library for IA metadata
my $perl5_dir = '/usr/local/ddg.cpan/perl5/lib/perl5/auto/share/module';
my $ddg_cache = $ENV{DDG_CACHE_DIR};

# $ia_metadata => {
#    id => { ... }
#    module => { ... }
#    sharedir => { ... }
# }
my %ia_metadata;

my %metadata_files = map { $_ => "$perl5_dir/DDG-$_-Meta/metadata.json" } qw(Goodie Spice Fathead Longtail);

sub build_metadata {
    my $self = shift;

    FILE: while (my ($type, $filename) = each %metadata_files) {
	warn "loading $filename";
        warn "IA type: $type Version: $versions{$type}" if debug;

        # One metadata file for each repo with the following format
        # { "<IA name>": {
        #     "id": " " 
        #     "signal" : " "
        #     ....
        # }
        my $file_data = decode_json_file($filename);

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

            my $perl_module = $module_data->{perl_module};
            my $sharedir = $self->_make_sharedir($perl_module);

            # create a new ia
            $ia_metadata{$perl_module} = {
                id => $module_data->{id},
                signal_from => $module_data->{signal_from} || $module_data->{id},
                status => $module_data->{status},
                example_query => $module_data->{example_query},
                name => $module_data->{name},
                description => $module_data->{description},
                repo => $module_data->{repo},
                tab => $module_data->{tab},
                perl_module => $perl_module,
                sharedir => $sharedir,
                sharedir_abs => $self->_make_sharedir_abs($sharedir),
                topic => $module_data->{topic},
                js_callback_name => $self->js_callback_name($perl_module)
            };

        }
    }
}

my %applied;

sub apply_keywords {
	my ($self, $target) = @_;

	return if exists $applied{$target};	

	$self->build_metadata unless %ia_metadata;

	warn "No metadata found for $target", return unless my $ia = $ia_metadata{$target};

	my $s = Package::Stash->new($target);

	while(my ($k, $v) = each %$ia){
		$s->add_symbol("&$k", sub { $v });
	}
	$s->add_symbol('&metadata', sub { $ia });
}

# get share directory path from perl module
sub _make_sharedir {
    my ($self, $class) = @_;
    my @classparts = grep{$_ ne 'DDG'} split('::', $class);
    my $v = $versions{ ucfirst $classparts[0]} || 0;
    my $sharedir = join('/', (map { s/([a-z])([A-Z])/$1_$2/g; lc } @classparts), $v);
    return $sharedir;
}

sub _make_sharedir_abs {
    my ($self, $sharedir) = @_;
    my $dir = dir($ddg_cache, 'share', $sharedir);
    return $dir;
}

# convert decimal and string version to int ex:  0.002 => 2
sub _convert_version {
    my ($v) = @_;
    $v =~ s/[^\d]+//g;
    $v += 0;
    return $v
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
