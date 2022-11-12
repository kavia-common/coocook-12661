package Coocook::Controller::Ajax::IngredientsEditor;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use JSON::MaybeXS;

BEGIN { extends 'Coocook::Controller' }

=head1 NAME

Coocook::Controller::AJAX::IngredientsEditor - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub project_base : Chained('/project/base') PathPart('') CaptureArgs(2)
  RequiresCapability('view_project') Does(~Ajax) {
    my ( $self, $c, $dish_or_recipe, $dish_or_recipe_id ) = @_;

    use feature 'say';
    use Data::Dumper;
    say Dumper( $c->{user} );

    return $c->detach('/error/not_found')
      unless ( $dish_or_recipe eq 'dish' or $dish_or_recipe eq 'recipe' );

    use feature 'say';
    use Data::Dumper;
    my $plural = $dish_or_recipe eq 'dish' ? 'dishes' : 'recipes';
    my $result = $c->project->recipes->find($dish_or_recipe_id)
      || $c->detach('/error/not_found');
    $c->stash( dish_or_recipe => $result );
}

sub get_all_ingredients : GET PathPart('ingredients') HEAD Chained('project_base')
  RequiresCapability('view_project') Does(~Ajax) {
    my ( $self, $c ) = @_;

    my $ingredients = $c->model('Ingredients')->new(
        project     => $c->project,
        ingredients => $c->stash->{dish_or_recipe}->ingredients,
    );

    $c->stash->{json_data} = $ingredients->for_ingredients_editor;
}

sub update_ingredient : POST PathPart('ingredients/update') Chained('project_base')
  RequiresCapability('edit_project') Does(~Ajax) {
    my ( $self, $c ) = @_;
    my $json       = $c->req->body_data;
    my $ingredient = $json->{ingredient};

    my $dish_or_recipe = $c->stash->{dish_or_recipe};

    my $ingrDB = $dish_or_recipe->search_related('ingredients')->find( $ingredient->{id} );
    $ingrDB->update(
        {
            value   => $ingredient->{value},
            unit_id => $ingredient->{current_unit}->{id},
            comment => $ingredient->{comment},
        }
    );

    $c->stash->{json_data} = { id => $ingrDB->id };
}

sub prepend_ingredient : POST PathPart('ingredients/prepend') Does('~Ajax') Chained('project_base')
  RequiresCapability('edit_project') Does(~Ajax) {
    my ( $self, $c ) = @_;

    my $dish_or_recipe = $c->stash->{dish_or_recipe};

    my $json          = $c->req->body_data;
    my $ingredient_id = $json->{ingredientId};
    my $prepare       = $json->{prepare};

    my $ingredient = $dish_or_recipe->search_related('ingredients')->find($ingredient_id);
    $ingredient->set_column( prepare => $prepare );
    $ingredient->move_first();

    $c->stash->{json_data} = { success => 1 };
}

sub append_ingredient : POST PathPart('ingredients/append') Does('~Ajax') Chained('project_base')
  RequiresCapability('edit_project') Does(~Ajax) {
    my ( $self, $c ) = @_;

    my $dish_or_recipe = $c->stash->{dish_or_recipe};

    my $json          = $c->req->body_data;
    my $ingredient_id = $json->{ingredientId};
    my $prepare       = $json->{prepare};

    my $ingredient = $dish_or_recipe->search_related('ingredients')->find($ingredient_id);
    $ingredient->set_column( prepare => $prepare );
    $ingredient->move_last();

    $c->stash->{json_data} = { success => 1 };
}

sub move_ingredient : POST PathPart('ingredients/move') Does('~Ajax') Chained('project_base')
  RequiresCapability('edit_project') Does(~Ajax) {
    my ( $self, $c ) = @_;

    my $dish_or_recipe = $c->stash->{dish_or_recipe};

    my $json      = $c->req->body_data;
    my $source_id = $json->{sourceId};
    my $target_id = $json->{targetId};
    my $direction = $json->{direction};

    my $source_db = $dish_or_recipe->search_related('ingredients')->find($source_id);
    my $target_db = $dish_or_recipe->search_related('ingredients')->find($target_id);

    my $new_position;
    if ( $direction == 'upwards' ) {
        $new_position = $target_db->position;
    }
    elsif ( $direction == 'downwards' ) {
        $new_position = $target_db->position + 1;
    }
    else {
        die "Invalid move direction `$direction`";
    }

    $source_db->move_to_group( { prepare => $target_db->prepare }, $new_position );
    $c->stash->{json_data} = { success => 1 };
}

sub delete_ingredient : POST PathPart('ingredients/delete') Does('~Ajax') Chained('project_base')
  RequiresCapability('edit_project') Does(~Ajax) {
    my ( $self, $c ) = @_;
    my $json = $c->req->body_data;

    my $dish_or_recipe = $c->stash->{dish_or_recipe};

    my $ingrDB = $dish_or_recipe->search_related('ingredients')->find( $json->{id} );
    $ingrDB->delete();

    $c->stash->{json_data} = { id => $ingrDB->id };
}

1;
