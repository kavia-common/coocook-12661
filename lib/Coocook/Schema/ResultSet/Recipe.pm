package Coocook::Schema::ResultSet::Recipe;

use Moose;
use namespace::autoclean;

extends 'Coocook::Schema::ResultSet';

__PACKAGE__->load_components('+Coocook::Schema::Component::ResultSet::SortByName');

__PACKAGE__->meta->make_immutable;

sub from_dish {
    my ( $self, $dish, %args ) = @_;

    return $self->txn_do(
        sub {
            my $recipe = $self->create(
                {
                    project_id => $dish->meal->project_id,
                    servings   => $dish->servings,
                    map { $_ => $args{$_} || $dish->get_column($_) }
                      qw(
                      name
                      description
                      preparation
                      )
                }
            );

            $recipe->set_tags( [ $dish->tags->all ] );

            $recipe->ingredients->copy_from_rs( $dish->ingredients );

            # TODO set from_recipe on dish? #179

            return $recipe;
        }
    );
}

sub public {
    my $self = shift;

    return $self->search(
        {
            -bool => 'project.is_public',
        },
        {
            join => 'project',
        }
    );
}

1;
