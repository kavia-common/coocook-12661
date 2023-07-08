package Coocook::Schema::ResultSet::UnitConversion;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'Coocook::Schema::ResultSet';

__PACKAGE__->meta->make_immutable;

sub transitive     { shift->search( { -bool     => 'transitive' } ) }
sub non_transitive { shift->search( { -not_bool => 'transitive' } ) }

1;
