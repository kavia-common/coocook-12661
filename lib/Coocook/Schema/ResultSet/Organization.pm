package Coocook::Schema::ResultSet::Organization;

use Moose;
use namespace::autoclean;

extends 'Coocook::Schema::ResultSet';

__PACKAGE__->load_components('+Coocook::Schema::Component::ResultSet::SortByName');

__PACKAGE__->meta->make_immutable;

1;
