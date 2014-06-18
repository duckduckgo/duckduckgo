package DDG::Block::Blockable::Any;
# ABSTRACT: Role for something blockable that has no triggers

use Moo::Role;

with 'DDG::Block::Blockable';

sub get_triggers {}
sub triggers {}

sub has_triggers { 0 }
sub triggers_block_type { 'Any' }

=head1 DESCRIPTION

=cut 

1;