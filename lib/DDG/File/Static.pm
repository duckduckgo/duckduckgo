package DDG::File::Static;

use Text::Zilla;

tzil_file 'TT';

use MooseX::Aliases;

has 'tt' => (
	isa => 'Template',
	is => 'ro',
	required => 1,
);
sub build_tzil_tt { shift->tt }

has 'template' => (
	isa => 'Str',
	is => 'ro',
	required => 1,
);
sub build_tzil_template { shift->template }

has '+tzil_stash' => (
	alias => 'stash',
);

sub to { shift->tzil_write_to(@_) }

1;