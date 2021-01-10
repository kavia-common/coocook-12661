package Coocook::Schema::Result::Unit;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'Coocook::Schema::Result';

__PACKAGE__->table('units');

__PACKAGE__->add_columns(
    id         => { data_type => 'integer', is_auto_increment => 1 },
    project_id => { data_type => 'integer' },
    space      => { data_type => 'boolean' },
    short_name => { data_type => 'text' },
    long_name  => { data_type => 'text' },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraints( [ 'project_id', 'long_name' ] );

__PACKAGE__->belongs_to( project => 'Coocook::Schema::Result::Project', 'project_id' );

# returns other convertible units of same quantity but not $self,
# for doc see https://metacpan.org/pod/DBIx::Class::Relationship::Base#Custom-join-conditions
__PACKAGE__->has_many(
    convertible_into => 'Coocook::Schema::Result::Unit',
    sub {
        my $args = shift;

        return {
            "$args->{foreign_alias}.id"          => { '!='   => { -ident => "$args->{self_alias}.id" } },
            "$args->{foreign_alias}.quantity_id" => { -ident => "$args->{self_alias}.quantity_id" },
            "$args->{foreign_alias}.to_quantity_default" => { '!=' => undef },
        };
    }
);

__PACKAGE__->has_many(
    articles_units => 'Coocook::Schema::Result::ArticleUnit',
    'unit_id',
    {
        cascade_delete => 0,    # units with articles_units may not be deleted
    }
);
__PACKAGE__->many_to_many( articles => articles_units => 'article' );

__PACKAGE__->has_many(
    dish_ingredients => 'Coocook::Schema::Result::DishIngredient',
    'unit_id',
    {
        cascade_delete => 0,    # units with dish_ingredients may not be deleted
    }
);
__PACKAGE__->many_to_many( dishes => dish_ingredients => 'dish' );

__PACKAGE__->has_many(
    recipe_ingredients => 'Coocook::Schema::Result::RecipeIngredient',
    'unit_id',
    {
        cascade_delete => 0,    # units with recipe_ingredients may not be deleted
    }
);
__PACKAGE__->many_to_many( recipes => recipe_ingredients => 'recipe' );

__PACKAGE__->has_many(
    items => 'Coocook::Schema::Result::Item',
    'unit_id',
    {
        cascade_delete => 0,    # units with items may not be deleted
    }
);

__PACKAGE__->meta->make_immutable;

1;
