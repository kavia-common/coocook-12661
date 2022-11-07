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
  FOREIGN KEY (unit1_id) REFERENCES units(id),
  FOREIGN KEY (unit2_id) REFERENCES units(id)
);

;
CREATE INDEX unit_conversions_idx_unit1_id ON unit_conversions (unit1_id);

;
CREATE INDEX unit_conversions_idx_unit2_id ON unit_conversions (unit2_id);

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

;

COMMIT;

