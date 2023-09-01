-- Convert schema 'share/ddl/_source/deploy/26/001-auto.yml' to 'share/ddl/_source/deploy/27/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE recipes ADD COLUMN created timestamp without time zone DEFAULT CURRENT_TIMESTAMP;

;

COMMIT;

