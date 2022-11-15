package Coocook::Schema::Component::ResultSet::Ingredient;

# ABSTRACT: common methods for ResultSet::DishIngredient and ResultSet::RecipeIngredient

use strict;
use warnings;

use feature 'fc';    # Perl v5.16

=head1 METHODS

=cut

sub sorted_by_columns { 'position' }

sub prepared     { shift->search( { -bool     => 'prepare' } ) }
sub not_prepared { shift->search( { -not_bool => 'prepare' } ) }

1;
