package Coocook::Schema::Component::ResultSet::Ingredient;

# ABSTRACT: common methods for ResultSet::DishIngredient and ResultSet::RecipeIngredient

use strict;
use warnings;

use feature 'fc';    # Perl v5.16

=head1 METHODS

=head2 copy_from_rs($resultset)

Copy ingredients from another dish or recipe.
Can copy from dish to recipe or vice versa.

=cut

sub copy_from_rs {
    my ( $self, $rs ) = @_;

    my @columns = qw( position prepare article_id unit_id value comment );

    # TODO could even use arrayref inflator for more speed
    $self->populate( [ $rs->search( undef, { columns => \@columns } )->hri->all ] );

    return $self;
}

sub sorted_by_columns { 'position' }

sub prepared     { shift->search( { -bool     => 'prepare' } ) }
sub not_prepared { shift->search( { -not_bool => 'prepare' } ) }

1;
