-- Convert schema 'share/ddl/_source/deploy/26/001-auto.yml' to 'share/ddl/_source/deploy/27/001-auto.yml':;

;
BEGIN;

-- need to create the new column with future default value
-- because SQLite doesn't support changing columns
ALTER TABLE recipes ADD COLUMN created timestamp without time zone DEFAULT CURRENT_TIMESTAMP;

-- reset existing rows to have a default of NULL
UPDATE recipes SET created = NULL;

;

COMMIT;

