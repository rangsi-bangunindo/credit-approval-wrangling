-- Purpose: Define the database schema for credit card approval data,
-- including main tables and their corresponding staging tables for raw CSV ingestion

DROP TABLE IF EXISTS application_record CASCADE;
DROP TABLE IF EXISTS credit_record CASCADE;

DROP TABLE IF EXISTS application_record_staging;
DROP TABLE IF EXISTS credit_record_staging;

-- Stores deduplicated applicant demographic and financial profile records
CREATE TABLE application_record (
    id                   BIGINT PRIMARY KEY,           -- Unique client ID
    code_gender          VARCHAR(1) NOT NULL,          -- Gender: 'M' or 'F'
    flag_own_car         CHAR(1) NOT NULL,             -- Owns a car: 'Y' or 'N'
    flag_own_realty      CHAR(1) NOT NULL,             -- Owns property: 'Y' or 'N'
    cnt_children         INTEGER NOT NULL,             -- Number of children
    amt_income_total     NUMERIC(12,2) NOT NULL,       -- Annual income
    name_income_type     VARCHAR(50) NOT NULL,         -- Income category
    name_education_type  VARCHAR(50) NOT NULL,         -- Education level
    name_family_status   VARCHAR(50) NOT NULL,         -- Marital status
    name_housing_type    VARCHAR(50) NOT NULL,         -- Housing type
    days_birth           INTEGER NOT NULL,             -- Age in days (negative)
    days_employed        INTEGER NOT NULL,             -- Employment days (negative or large positive if unemployed)
    flag_mobil           SMALLINT NOT NULL,            -- Has mobile phone
    flag_work_phone      SMALLINT NOT NULL,            -- Has work phone
    flag_phone           SMALLINT NOT NULL,            -- Has home phone
    flag_email           SMALLINT NOT NULL,            -- Has email
    occupation_type      VARCHAR(50),                  -- Occupation (nullable)
    cnt_fam_members      NUMERIC(4,1) NOT NULL         -- Family size
);

-- No constraints to allow raw CSV loading (even with duplicates)
-- Purpose: Load raw application data from CSV into a staging table,
-- then deduplicate and insert clean data into the main table
CREATE TABLE application_record_staging (
    id                   BIGINT,
    code_gender          VARCHAR(1),
    flag_own_car         CHAR(1),
    flag_own_realty      CHAR(1),
    cnt_children         INTEGER,
    amt_income_total     NUMERIC(12,2),
    name_income_type     VARCHAR(50),
    name_education_type  VARCHAR(50),
    name_family_status   VARCHAR(50),
    name_housing_type    VARCHAR(50),
    days_birth           INTEGER,
    days_employed        INTEGER,
    flag_mobil           SMALLINT,
    flag_work_phone      SMALLINT,
    flag_phone           SMALLINT,
    flag_email           SMALLINT,
    occupation_type      VARCHAR(50),
    cnt_fam_members      NUMERIC(4,1)
);

-- Stores status records associated with applicants linked to the same ID
CREATE TABLE credit_record (
    id               BIGINT NOT NULL,          -- Foreign key to application_record
    months_balance   INTEGER NOT NULL,         -- Month index (0 = now, -1 = last month, etc.)
    status           VARCHAR(1) NOT NULL,      -- Credit status code: 0–5, C, X
    FOREIGN KEY (id) REFERENCES application_record(id)
);

-- No constraints to allow raw CSV loading
CREATE TABLE credit_record_staging (
    id               BIGINT,
    months_balance   INTEGER,
    status           VARCHAR(2)
);