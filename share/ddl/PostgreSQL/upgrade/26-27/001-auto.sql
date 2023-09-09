-- Convert schema 'share/ddl/_source/deploy/26/001-auto.yml' to 'share/ddl/_source/deploy/27/001-auto.yml':;

;
BEGIN;

-- create table with NULL as default
ALTER TABLE recipes ADD COLUMN created timestamp without time zone;

-- set default value for future rows
ALTER TABLE recipes ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;

;

COMMIT;

