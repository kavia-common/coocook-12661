-- Convert schema 'share/ddl/_source/deploy/25/001-auto.yml' to 'share/ddl/_source/deploy/26/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "unit_conversions" (
  "id" serial NOT NULL,
  "unit1_id" integer NOT NULL,
  "factor" real NOT NULL,
  "unit2_id" integer NOT NULL,
  "transitive" boolean DEFAULT '1' NOT NULL,
  "comment" text DEFAULT '' NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "unit_conversions_idx_unit1_id" on "unit_conversions" ("unit1_id");
CREATE INDEX "unit_conversions_idx_unit2_id" on "unit_conversions" ("unit2_id");

;
ALTER TABLE "unit_conversions" ADD CONSTRAINT "unit_conversions_fk_unit1_id" FOREIGN KEY ("unit1_id")
  REFERENCES "units" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "unit_conversions" ADD CONSTRAINT "unit_conversions_fk_unit2_id" FOREIGN KEY ("unit2_id")
  REFERENCES "units" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE units DROP CONSTRAINT units_fk_quantity_id;

;
DROP INDEX units_idx_quantity_id;

;
ALTER TABLE units DROP COLUMN quantity_id;

;
ALTER TABLE units DROP COLUMN to_quantity_default;

;
ALTER TABLE units DROP COLUMN space;

;
DROP TABLE quantities CASCADE;

;

COMMIT;

