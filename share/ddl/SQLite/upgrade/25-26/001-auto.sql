-- Convert schema 'share/ddl/_source/deploy/25/001-auto.yml' to 'share/ddl/_source/deploy/26/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE unit_conversions (
  id INTEGER PRIMARY KEY NOT NULL,
  unit1_id integer NOT NULL,
  factor real NOT NULL,
  unit2_id integer NOT NULL,
  transitive boolean NOT NULL DEFAULT 1,
  comment text NOT NULL DEFAULT '',
  FOREIGN KEY (unit1_id) REFERENCES units(id) ON DELETE CASCADE,
  FOREIGN KEY (unit2_id) REFERENCES units(id) ON DELETE CASCADE
);

;
CREATE INDEX unit_conversions_idx_unit1_id ON unit_conversions (unit1_id);

;
CREATE INDEX unit_conversions_idx_unit2_id ON unit_conversions (unit2_id);

-- convert old "to_quantity_default" columns to "unit_conversions" rows
INSERT INTO unit_conversions(
    unit1_id,
    factor,
    unit2_id
)
SELECT
    units.id,
    units.to_quantity_default,
    quantities.default_unit_id
FROM units
JOIN quantities ON units.quantity_id = quantities.id
JOIN units default_unit ON default_unit_id = default_unit.id
WHERE
        units.to_quantity_default IS NOT NULL
    AND units.id != default_unit.id
;

-- normalize to unit1_id < unit2_id
UPDATE unit_conversions
SET
    (unit1_id, unit2_id) = (unit2_id, unit1_id),
    factor = 1 / factor
WHERE unit1_id > unit2_id;

;
DROP INDEX IF EXISTS dish_ingredients_fk_article_id_unit_id;

;
DROP INDEX IF EXISTS dish_ingredients_idx_article_id_unit_id;

;
DROP INDEX IF EXISTS dish_ingredients_fk_article_id_unit_id;
DROP INDEX IF EXISTS items_fk_article_id_unit_id;

;
DROP INDEX IF EXISTS dish_ingredients_idx_article_id_unit_id;
DROP INDEX IF EXISTS items_idx_article_id_unit_id;

;
DROP INDEX IF EXISTS recipe_ingredients_fk_article_id_unit_id;
DROP INDEX IF EXISTS recipe_ingredients_fk_article_id_unit_id;

;
DROP INDEX IF EXISTS recipe_ingredients_idx_article_id_unit_id;
DROP INDEX IF EXISTS recipe_ingredients_idx_article_id_unit_id;

;
CREATE TEMPORARY TABLE units_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  project_id integer NOT NULL,
  short_name text NOT NULL,
  long_name text NOT NULL
);

;
INSERT INTO units_temp_alter( id, project_id, short_name, long_name) SELECT id, project_id, short_name, long_name FROM units;

PRAGMA defer_foreign_keys = true;

;
DROP TABLE units;

;
CREATE TABLE units (
  id INTEGER PRIMARY KEY NOT NULL,
  project_id integer NOT NULL,
  short_name text NOT NULL,
  long_name text NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

;
CREATE INDEX units_idx_project_id ON units (project_id);

;
CREATE UNIQUE INDEX units_project_id_long_name ON units (project_id, long_name);

;
INSERT INTO units SELECT id, project_id, short_name, long_name FROM units_temp_alter;

;
DROP TABLE units_temp_alter;

;
DROP TABLE quantities;

-- Drop foreign key from dish_ingredients on article_units
-- We need to copy table and recreate it without FOREIGN KEY,
-- because SQLite has no ALTER TABLE
CREATE TEMPORARY TABLE dish_ingredients_tmp (
  id INTEGER PRIMARY KEY NOT NULL,
  position integer NOT NULL DEFAULT 1,
  dish_id integer NOT NULL,
  prepare boolean NOT NULL,
  article_id integer NOT NULL,
  unit_id integer NOT NULL,
  value real NOT NULL,
  comment text NOT NULL,
  item_id integer
);

INSERT INTO dish_ingredients_tmp SELECT * FROM dish_ingredients;
DROP TABLE dish_ingredients;

CREATE TABLE dish_ingredients (
  id INTEGER PRIMARY KEY NOT NULL,
  position integer NOT NULL DEFAULT 1,
  dish_id integer NOT NULL,
  prepare boolean NOT NULL,
  article_id integer NOT NULL,
  unit_id integer NOT NULL,
  value real NOT NULL,
  comment text NOT NULL,
  item_id integer,
  FOREIGN KEY (article_id) REFERENCES articles(id),
  FOREIGN KEY (dish_id) REFERENCES dishes(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE SET NULL,
  FOREIGN KEY (unit_id) REFERENCES units(id)
);

INSERT INTO dish_ingredients SELECT * FROM dish_ingredients_tmp;
DROP TABLE dish_ingredients_tmp;

CREATE INDEX dish_ingredients_idx_article_id ON dish_ingredients (article_id);
CREATE INDEX dish_ingredients_idx_dish_id ON dish_ingredients (dish_id);
CREATE INDEX dish_ingredients_idx_item_id ON dish_ingredients (item_id);
CREATE INDEX dish_ingredients_idx_unit_id ON dish_ingredients (unit_id);

-- Drop foreign key from recipe_ingredients on article_units
-- We need to copy table and recreate it without FOREIGN KEY,
-- because SQLite has no ALTER TABLE
CREATE TEMPORARY TABLE recipe_ingredients_tmp (
  id INTEGER PRIMARY KEY NOT NULL,
  position integer NOT NULL DEFAULT 1,
  recipe_id integer NOT NULL,
  prepare boolean NOT NULL,
  article_id integer NOT NULL,
  unit_id integer NOT NULL,
  value real NOT NULL,
  comment text NOT NULL
);

INSERT INTO recipe_ingredients_tmp SELECT * FROM recipe_ingredients;
DROP TABLE recipe_ingredients;

CREATE TABLE recipe_ingredients (
  id INTEGER PRIMARY KEY NOT NULL,
  position integer NOT NULL DEFAULT 1,
  recipe_id integer NOT NULL,
  prepare boolean NOT NULL,
  article_id integer NOT NULL,
  unit_id integer NOT NULL,
  value real NOT NULL,
  comment text NOT NULL,
  FOREIGN KEY (article_id) REFERENCES articles(id),
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id)
);

INSERT INTO recipe_ingredients SELECT * FROM recipe_ingredients_tmp;
DROP TABLE recipe_ingredients_tmp;

CREATE INDEX recipe_ingredients_idx_article_id ON recipe_ingredients (article_id);
CREATE INDEX recipe_ingredients_idx_recipe_id ON recipe_ingredients (recipe_id);
CREATE INDEX recipe_ingredients_idx_unit_id ON recipe_ingredients (unit_id);

-- Drop foreign key from items on article_units
-- We need to copy table and recreate it without FOREIGN KEY,
-- because SQLite has no ALTER TABLE
CREATE TEMPORARY TABLE items_tmp (
  id INTEGER PRIMARY KEY NOT NULL,
  purchase_list_id integer NOT NULL,
  value real NOT NULL,
  offset real NOT NULL DEFAULT 0,
  unit_id integer NOT NULL,
  article_id integer NOT NULL,
  purchased boolean NOT NULL DEFAULT 0,
  comment text NOT NULL
);

INSERT INTO items_tmp SELECT * FROM items;
DROP TABLE items;

CREATE TABLE items (
  id INTEGER PRIMARY KEY NOT NULL,
  purchase_list_id integer NOT NULL,
  value real NOT NULL,
  offset real NOT NULL DEFAULT 0,
  unit_id integer NOT NULL,
  article_id integer NOT NULL,
  purchased boolean NOT NULL DEFAULT 0,
  comment text NOT NULL,
  FOREIGN KEY (article_id) REFERENCES articles(id),
  FOREIGN KEY (purchase_list_id) REFERENCES purchase_lists(id) ON DELETE CASCADE,
  FOREIGN KEY (unit_id) REFERENCES units(id)
);

INSERT INTO items SELECT * FROM items_tmp;
DROP TABLE items_tmp;

CREATE INDEX items_idx_article_id ON items (article_id);
CREATE INDEX items_idx_purchase_list_id ON items (purchase_list_id);
CREATE INDEX items_idx_unit_id ON items (unit_id);
CREATE UNIQUE INDEX items_purchase_list_id_article_id_unit_id ON items (purchase_list_id, article_id, unit_id);

COMMIT;
