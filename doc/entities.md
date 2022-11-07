# Entities
## Article
**table:** articles

### Attributes
#### id
**type:** integer

Primary key of `Article` for database.

#### project\_id
**type:** integer

Foreign key on `Project`. References the `Project` that this `Article` was created or imported in.

#### shop\_section\_id
**type:** integer

Foreign key on `ShopSection`. References the `ShopSection` where this `Article` can be found.

#### shelf\_life\_days
**type:** integer

Indicates how many days the `Article` could be stored, before it has to be processed.

#### preorder\_servings
**type:** integer


#### preorder\_workdays
**type:** integer


#### name
**type:** integer

Human-readable name of the `Article`.

#### comment
**type:** text

User specified comment of the `Article`.


## Unit
**table:** units

### Attributes
#### id
**type:** integer

Primary key of `Unit` for database.

#### project\_id
**type:** integer

Foreign key on `Project`. References the `Project` that this `Unit` was created or imported in.

#### short\_name
**type:** text

Human-readable short variant of the name of the `Unit`. E.g.: `kg` for Kilogram.

#### long\_name
**type:** text

Human-readable long variant of the name of the `Unit`. E.g.: `Kilogram` for Kilogram.


## UnitConversions
**table:** unit\_conversions

### Attributes
#### id
**type:** integer

#### unit1\_id
**type:** integer

#### factor
**type:** real

#### unit1\_id
**type:** integer

#### transitive
**type:** boolean

Defines if this conversion can be extended to convert into other units.
Some very special conversions might be non-transitive.

#### comment
**type:** text

User defined comment for conversion.
Could be an academic resource that specifies the conversion factor.

## DishIngredient
**table:** dish\_ingredients

### Attributes
#### id
**type:** integer

Primary key of `DishIngredient` for database.

#### position
**type:** integer

Position of the `DishIngredient` in the `IngredientsEditor`.

#### dish\_id
**type:** integer

Foreign key on the `id` of a `Dish`. References the `Dish` that this `DishIngredient` belongs to.

#### prepare
**type:** boolean

Indicates wether this `DishIngredient` has to be prepared before processing or not.

#### article\_id
**type:** integer

Foreign key on the `id` of an `Article`. References the `Article` that this `DishIngredient` is derived from.

#### unit\_id
**type:** integer

Foreign key on the `id` of an `Unit`. References the `Unit` this `DishIngredient` is in.

#### value
**type:** real

Current value of the `DishIngredient`.

#### comment
**type:** text

User specified comment of the `DishIngredient`.

#### item\_id
**type:** integer

Foreign key on `id` of `Item`. References the `Item` on a `PurchaseList` that belongs to this `DishIngredient`.

