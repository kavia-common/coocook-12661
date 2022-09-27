-- Convert schema 'share/ddl/_source/deploy/24/001-auto.yml' to 'share/ddl/_source/deploy/25/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE dishes ADD COLUMN position integer DEFAULT 1 NOT NULL;

;
ALTER TABLE meals ADD COLUMN position integer DEFAULT 1 NOT NULL;

;

COMMIT;

