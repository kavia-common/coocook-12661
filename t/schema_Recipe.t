use Test2::V0;

use lib 't/lib';
use TestDB;

subtest duplicate => sub {
    my $db = TestDB->new;

    my $recipe = $db->resultset('Recipe')->find(1);

    ok my $clone = $recipe->duplicate( { name => 'clone recipe' } ), "clone";

    isa_ok $clone => 'Coocook::Schema::Result::Recipe';

    isnt $clone->id => $recipe->id, "IDs differ";

    is $clone->ingredients->count => $recipe->ingredients->count, "number of ingredients equal";
};

subtest from_dish => sub {
    my $db = TestDB->new;

    my $dish = $db->resultset('Dish')->find(1);

    ok my $recipe = $db->resultset('Recipe')->from_dish($dish);

    is [ $recipe->ingredients->hri->all ] => bag {
        item hash {
            field position   => 1;
            field value      => 500.0;    # half as in recipe
            field unit_id    => 1;        # grams
            field article_id => 1;        # flour
            etc;
        };
        item hash { field position => 2; etc };
        item hash { field position => 3; etc };
    };
};

subtest from_recipe => sub {
    my $db = TestDB->new;

    my $recipe = $db->resultset('Recipe')->find(1);

    ok my $dish = $db->resultset('Dish')->from_recipe(
        $recipe,
        meal     => 1,
        comment  => __FILE__,
        servings => 2,          # half as recipe
    );

    is $dish->from_recipe_id => $recipe->id;
    is $dish->servings       => 2;
    is $dish->comment        => __FILE__;

    is [ $dish->ingredients->hri->all ] => bag {
        item hash {
            field position   => 1;
            field value      => 0.25;    # half as in recipe
            field unit_id    => 3;       # liters
            field article_id => 3;       # water
            etc;
        };
        item hash { field position => 2; etc };
        item hash { field position => 3; etc };
        item hash { field position => 4; etc };
    };
};

done_testing;
