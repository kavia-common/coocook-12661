package Coocook::Schema::ResultSet::DishIngredient;

use Moose;
use namespace::autoclean;

extends 'Coocook::Schema::ResultSet';

__PACKAGE__->load_components(
    '+Coocook::Schema::Component::ResultSet::Ingredient',
    '+Coocook::Schema::Component::ResultSet::SortByName',
);

__PACKAGE__->meta->make_immutable;

sub unassigned {
    my $self = shift;

    return $self->search( { item_id => undef } );
}

1;
