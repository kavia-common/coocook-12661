-- Convert schema 'share/ddl/_source/deploy/24/001-auto.yml' to 'share/ddl/_source/deploy/25/001-auto.yml':;

;
BEGIN;

--
-- Table: dishes
--

CREATE TEMPORARY TABLE dishes_tmp (
  id INTEGER PRIMARY KEY NOT NULL,
  meal_id integer NOT NULL,
  from_recipe_id integer,
  name text NOT NULL,
  servings integer NOT NULL,
  prepare_at_meal_id integer,
  preparation text NOT NULL,
  description text NOT NULL,
  comment text NOT NULL
);

INSERT INTO dishes_tmp SELECT * FROM dishes;
DROP TABLE dishes;

CREATE TABLE dishes (
  id INTEGER PRIMARY KEY NOT NULL,
  meal_id integer NOT NULL,
  position integer NOT NULL,
  from_recipe_id integer,
  name text NOT NULL,
  servings integer NOT NULL,
  prepare_at_meal_id integer,
  preparation text NOT NULL,
  description text NOT NULL,
  comment text NOT NULL,
  FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE,
  FOREIGN KEY (prepare_at_meal_id) REFERENCES meals(id),
  FOREIGN KEY (from_recipe_id) REFERENCES recipes(id)
);

INSERT INTO dishes
    SELECT
        id,
        meal_id,
        ROW_NUMBER () OVER (
            PARTITION BY meal_id
        ) position,
        from_recipe_id,
        name,
        servings,
        prepare_at_meal_id,
        preparation,
        description,
        comment
    FROM dishes_tmp;

CREATE INDEX dishes_idx_meal_id ON dishes (meal_id);
CREATE INDEX dishes_idx_prepare_at_meal_id ON dishes (prepare_at_meal_id);
CREATE INDEX dishes_idx_from_recipe_id ON dishes (from_recipe_id);

DROP TABLE dishes_tmp;

--
-- Table: meals
--
CREATE TEMPORARY TABLE meals_tmp (
  id INTEGER PRIMARY KEY NOT NULL,
  project_id integer NOT NULL,
  date date NOT NULL,
  name text NOT NULL,
  comment text NOT NULL
);

INSERT INTO meals_tmp SELECT * FROM meals;
DROP TABLE meals;

CREATE TABLE meals (
  id INTEGER PRIMARY KEY NOT NULL,
  project_id integer NOT NULL,
  position integer NOT NULL,
  date date NOT NULL,
  name text NOT NULL,
  comment text NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

INSERT INTO meals
    SELECT
        id,
        project_id,
        ROW_NUMBER () OVER (
            PARTITION BY project_id
            ORDER BY name ASC
        ) position,
        date,
        name,
        comment
    FROM meals_tmp;

CREATE INDEX meals_idx_project_id ON meals (project_id);
CREATE UNIQUE INDEX meals_project_id_date_name ON meals (project_id, date, name);

DROP TABLE meals_tmp;

COMMIT;
