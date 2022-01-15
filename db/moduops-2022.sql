BEGIN TRANSACTION;
DROP TABLE IF EXISTS "carType";
CREATE TABLE IF NOT EXISTS "carType" (
	"class"	Text,
	"era"	Text,
	"code"	Text,
	"description"	Text NOT NULL,
	"short"	Text NOT NULL,
	"length"	Text NOT NULL,
	"remarks"	Text,
	"id"	Text NOT NULL,
	"max"	Text,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_UUID" UNIQUE("id")
);
DROP TABLE IF EXISTS "country";
CREATE TABLE IF NOT EXISTS "country" (
	"id"	Integer,
	"name"	Text NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_ID" UNIQUE("id")
);
DROP TABLE IF EXISTS "state";
CREATE TABLE IF NOT EXISTS "state" (
	"id"	Integer,
	"name"	Text,
	"countryId"	Integer,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_id" UNIQUE("id")
);
DROP TABLE IF EXISTS "train";
CREATE TABLE IF NOT EXISTS "train" (
	"symbol"	Text NOT NULL,
	"route"	Text,
	"id"	Text NOT NULL,
	"origin"	Text NOT NULL,
	"destination"	Text NOT NULL,
	"length"	Integer NOT NULL,
	"name"	Text,
	"note"	Text,
	"overview"	Text,
	"instructions"	Text,
	"orders"	Text,
	"limitModules"	Integer,
	"excludeTypes"	Text,
	"type"	Text,
	"terminationInstructions"	Text,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_symbol" UNIQUE("symbol")
);
DROP TABLE IF EXISTS "workList";
CREATE TABLE IF NOT EXISTS "workList" (
	"id"	Text NOT NULL,
	"direction"	Text,
	"moduleId"	Text,
	"spotId"	Text,
	"cpw"	Integer,
	"carId"	Text,
	"consigneeId"	Text,
	"active"	Text,
	"stop"	Integer,
	"cumtotal"	Integer,
	"trainDir"	Text,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_id" UNIQUE("id")
);
DROP TABLE IF EXISTS "consignee";
CREATE TABLE IF NOT EXISTS "consignee" (
	"name"	Text NOT NULL,
	"moduleId"	Text NOT NULL,
	"remarks"	Text,
	"id"	Text NOT NULL,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_UUID" UNIQUE("id"),
	CONSTRAINT "lnk_module_consignee" FOREIGN KEY("moduleId") REFERENCES "module"("id") ON DELETE Cascade ON UPDATE Cascade
);
DROP TABLE IF EXISTS "manifest";
CREATE TABLE IF NOT EXISTS "manifest" (
	"id"	Integer NOT NULL,
	"trainId"	Text NOT NULL,
	"workorderId"	Text,
	"stop"	Integer NOT NULL,
	"trainOrder"	Text,
	CONSTRAINT "unique_ID" UNIQUE("id"),
	CONSTRAINT "lnk_workorder_manifest" FOREIGN KEY("workorderId") REFERENCES "workorder"("id") ON DELETE Cascade,
	CONSTRAINT "lnk_train_manifest" FOREIGN KEY("trainId") REFERENCES "train"("id") ON DELETE Cascade
);
DROP TABLE IF EXISTS "module";
CREATE TABLE IF NOT EXISTS "module" (
	"short_name"	Text NOT NULL,
	"owner"	Text,
	"name"	Text NOT NULL,
	"size"	Text,
	"city"	Text,
	"state"	Text,
	"description"	Text,
	"remarks"	Text,
	"organizationId"	Text,
	"passing"	Integer,
	"ownerId"	Text,
	"isYard"	Boolean,
	"id"	Text NOT NULL,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_UUID" UNIQUE("id")
);
DROP TABLE IF EXISTS "organization";
CREATE TABLE IF NOT EXISTS "organization" (
	"name"	Text NOT NULL,
	"website"	Text,
	"contactId"	Text,
	"regionId"	Integer,
	"id"	Text NOT NULL,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_UUID" UNIQUE("id")
);
DROP TABLE IF EXISTS "person";
CREATE TABLE IF NOT EXISTS "person" (
	"id"	Integer NOT NULL,
	"firstName"	Text NOT NULL,
	"lastName"	Text NOT NULL,
	"cityId"	Integer,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_UUID" UNIQUE("id")
);
DROP TABLE IF EXISTS "region";
CREATE TABLE IF NOT EXISTS "region" (
	"id"	Integer NOT NULL,
	"regionName"	Text NOT NULL,
	"stateId"	Integer,
	"countryId"	Integer,
	"lat"	Text,
	"lon"	Text,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_UUID" UNIQUE("id"),
	CONSTRAINT "unique_countryID" UNIQUE("countryId")
);
DROP TABLE IF EXISTS "route";
CREATE TABLE IF NOT EXISTS "route" (
	"id"	Integer NOT NULL,
	"stop"	Integer NOT NULL,
	"stopId"	Text NOT NULL,
	"trainId"	Text NOT NULL,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_ID" UNIQUE("id")
);
DROP TABLE IF EXISTS "schedule";
CREATE TABLE IF NOT EXISTS "schedule" (
	"id"	Integer NOT NULL,
	"trainId"	Integer NOT NULL,
	"day"	Integer,
	"hour"	Integer,
	"min"	Integer,
	"ampm"	Text,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_id" UNIQUE("id")
);
DROP TABLE IF EXISTS "spot";
CREATE TABLE IF NOT EXISTS "spot" (
	"track"	Integer,
	"spot"	Text NOT NULL,
	"moduleId"	Text NOT NULL,
	"length"	Integer NOT NULL,
	"direction"	Text,
	"used"	Text,
	"active"	Boolean,
	"isYard"	Boolean,
	"id"	Text NOT NULL,
	PRIMARY KEY("id"),
	CONSTRAINT "lnk_module_spot" FOREIGN KEY("moduleId") REFERENCES "module"("id") ON DELETE Cascade ON UPDATE Cascade
);
DROP TABLE IF EXISTS "spotCarType";
CREATE TABLE IF NOT EXISTS "spotCarType" (
	"spotId"	Text,
	"carTypeId"	Text,
	"quantity"	Integer,
	CONSTRAINT "lnk_spot_MM_carType" FOREIGN KEY("spotId") REFERENCES "spot"("id") ON DELETE Cascade,
	CONSTRAINT "lnk_carType_MM_spot" FOREIGN KEY("carTypeId") REFERENCES "carType"("id") ON DELETE Cascade
);
DROP TABLE IF EXISTS "city";
CREATE TABLE IF NOT EXISTS "city" (
	"id"	Integer,
	"name"	Text,
	"stateId"	Integer,
	PRIMARY KEY("id" AUTOINCREMENT),
	CONSTRAINT "unique_id" UNIQUE("id")
);
DROP TABLE IF EXISTS "workorder";
CREATE TABLE IF NOT EXISTS "workorder" (
	"carId"	Text NOT NULL,
	"spotId"	Text NOT NULL,
	"consigneeId"	Text NOT NULL,
	"cpw"	Integer NOT NULL,
	"remarks"	Text,
	"id"	Text NOT NULL,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_UUID" UNIQUE("id"),
	CONSTRAINT "lnk_carType_workorder" FOREIGN KEY("carId") REFERENCES "carType"("id") ON DELETE Cascade,
	CONSTRAINT "lnk_spot_workorder" FOREIGN KEY("spotId") REFERENCES "spot"("id") ON DELETE Cascade,
	CONSTRAINT "lnk_consignee_workorder" FOREIGN KEY("consigneeId") REFERENCES "consignee"("id") ON DELETE Cascade
);
DROP TABLE IF EXISTS "config";
CREATE TABLE IF NOT EXISTS "config" (
	"id"	Text NOT NULL,
	"value"	Text,
	PRIMARY KEY("id"),
	CONSTRAINT "unique_name" UNIQUE("id")
);
DROP INDEX IF EXISTS "index_UUID";
CREATE INDEX IF NOT EXISTS "index_UUID" ON "carType" (
	"id"
);
DROP INDEX IF EXISTS "index_countryID";
CREATE INDEX IF NOT EXISTS "index_countryID" ON "state" (
	"countryId"
);
DROP INDEX IF EXISTS "index_UUID1";
CREATE INDEX IF NOT EXISTS "index_UUID1" ON "consignee" (
	"id"
);
DROP INDEX IF EXISTS "index_moduleID1";
CREATE INDEX IF NOT EXISTS "index_moduleID1" ON "consignee" (
	"moduleId"
);
DROP INDEX IF EXISTS "index_trainID";
CREATE INDEX IF NOT EXISTS "index_trainID" ON "manifest" (
	"trainId"
);
DROP INDEX IF EXISTS "index_UUID4";
CREATE INDEX IF NOT EXISTS "index_UUID4" ON "module" (
	"id"
);
DROP INDEX IF EXISTS "index_isYard";
CREATE INDEX IF NOT EXISTS "index_isYard" ON "module" (
	"isYard"
);
DROP INDEX IF EXISTS "index_organizationID";
CREATE INDEX IF NOT EXISTS "index_organizationID" ON "module" (
	"organizationId"
);
DROP INDEX IF EXISTS "index_ownerID";
CREATE INDEX IF NOT EXISTS "index_ownerID" ON "module" (
	"ownerId"
);
DROP INDEX IF EXISTS "index_contactID";
CREATE INDEX IF NOT EXISTS "index_contactID" ON "organization" (
	"contactId"
);
DROP INDEX IF EXISTS "index_regionID";
CREATE INDEX IF NOT EXISTS "index_regionID" ON "organization" (
	"regionId"
);
DROP INDEX IF EXISTS "index_cityID";
CREATE INDEX IF NOT EXISTS "index_cityID" ON "region" (
	"stateId"
);
DROP INDEX IF EXISTS "index_trainUUID";
CREATE INDEX IF NOT EXISTS "index_trainUUID" ON "route" (
	"trainId"
);
DROP INDEX IF EXISTS "index_day";
CREATE INDEX IF NOT EXISTS "index_day" ON "schedule" (
	"day"
);
DROP INDEX IF EXISTS "index_trainID1";
CREATE INDEX IF NOT EXISTS "index_trainID1" ON "schedule" (
	"trainId"
);
DROP INDEX IF EXISTS "index_UUID2";
CREATE INDEX IF NOT EXISTS "index_UUID2" ON "spot" (
	"id"
);
DROP INDEX IF EXISTS "index_isYard1";
CREATE INDEX IF NOT EXISTS "index_isYard1" ON "spot" (
	"isYard"
);
DROP INDEX IF EXISTS "index_moduleID";
CREATE INDEX IF NOT EXISTS "index_moduleID" ON "spot" (
	"moduleId"
);
DROP INDEX IF EXISTS "index_carType_id";
CREATE INDEX IF NOT EXISTS "index_carType_id" ON "spotCarType" (
	"carTypeId"
);
DROP INDEX IF EXISTS "index_spot_id";
CREATE INDEX IF NOT EXISTS "index_spot_id" ON "spotCarType" (
	"spotId"
);
DROP INDEX IF EXISTS "index_stateID";
CREATE INDEX IF NOT EXISTS "index_stateID" ON "city" (
	"stateId"
);
DROP INDEX IF EXISTS "index_id3";
CREATE INDEX IF NOT EXISTS "index_id3" ON "workorder" (
	"id"
);
COMMIT;
