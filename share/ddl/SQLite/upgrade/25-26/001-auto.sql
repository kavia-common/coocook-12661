-- Convert schema 'share/ddl/_source/deploy/25/001-auto.yml' to 'share/ddl/_source/deploy/26/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE units_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  project_id integer NOT NULL,
  space boolean NOT NULL,
  short_name text NOT NULL,
  long_name text NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

;
INSERT INTO units_temp_alter( id, project_id, space, short_name, long_name) SELECT id, project_id, space, short_name, long_name FROM units;

;
DROP TABLE units;

;
CREATE TABLE units (
  id INTEGER PRIMARY KEY NOT NULL,
  project_id integer NOT NULL,
  space boolean NOT NULL,
  short_name text NOT NULL,
  long_name text NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

;
CREATE INDEX units_idx_project_id ON units (project_id);

;
CREATE UNIQUE INDEX units_project_id_long_name ON units (project_id, long_name);

;
INSERT INTO units SELECT id, project_id, space, short_name, long_name FROM units_temp_alter;

;
DROP TABLE units_temp_alter;

;
DROP TABLE quantities;

;

COMMIT;

