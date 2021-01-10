-- Convert schema 'share/ddl/_source/deploy/25/001-auto.yml' to 'share/ddl/_source/deploy/26/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE units DROP CONSTRAINT units_fk_quantity_id;

;
DROP INDEX units_idx_quantity_id;

;
ALTER TABLE units DROP COLUMN quantity_id;

;
ALTER TABLE units DROP COLUMN to_quantity_default;

;
DROP TABLE quantities CASCADE;

;

COMMIT;

