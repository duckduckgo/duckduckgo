package DDG::Meta::Block;

use strict;
use warnings;
use Carp;
use Hash::Util qw( lock_keys legal_keys );
use DDG::Block::Blockable::Triggers;

sub apply_keywords {
	my ( $class, $target ) = @_;
	
	#
	# triggers
	#
	
	{
		my $triggers;
		no strict "refs";

		*{"${target}::triggers_block_type"} = sub { $triggers->block_type };
		*{"${target}::get_triggers"} = sub { $triggers->get };
		*{"${target}::has_triggers"} = sub { $triggers ? 1 : 0 };
		*{"${target}::triggers"} = sub {
			$triggers = DDG::Block::Blockable::Triggers->new unless $triggers;
			$triggers->add(@_)
		};
	}

}

1;
