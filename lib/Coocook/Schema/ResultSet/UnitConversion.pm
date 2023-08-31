package Coocook::Schema::ResultSet::UnitConversion;

use Moose;
use namespace::autoclean;

extends 'Coocook::Schema::ResultSet';

__PACKAGE__->meta->make_immutable;

sub transitive     { shift->search( { -bool     => 'transitive' } ) }
sub non_transitive { shift->search( { -not_bool => 'transitive' } ) }

1;
