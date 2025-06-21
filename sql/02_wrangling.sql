-- Purpose: Clean, transform the data, and output structured datasets,
-- following best practices in data preparation

TRUNCATE TABLE application_record, credit_record;

-- Insert only unique (non-duplicate) application records from the staging table
-- (IDs that appear exactly once in the staging table)
INSERT INTO application_record (
    id, code_gender,
    flag_own_car,
    flag_own_realty,
    cnt_children, amt_income_total,
    name_income_type,
    name_education_type,
    name_family_status,
    name_housing_type,
    days_birth,
    days_employed,
    flag_mobil,
    flag_work_phone,
    flag_phone,
    flag_email,
    occupation_type,
    cnt_fam_members
)
SELECT
    s.id,
    s.code_gender,
    s.flag_own_car,
    s.flag_own_realty,
    s.cnt_children,
    s.amt_income_total,
    s.name_income_type,
    s.name_education_type,
    s.name_family_status,
    s.name_housing_type,
    s.days_birth,
    s.days_employed,
    s.flag_mobil,
    s.flag_work_phone,
    s.flag_phone,
    s.flag_email,
    s.occupation_type,
    s.cnt_fam_members
FROM application_record_staging s

-- Only keep rows where the ID appears exactly once in the staging table
JOIN (
    SELECT id
    FROM application_record_staging
    GROUP BY id
    HAVING COUNT(*) = 1
) AS unique_ids
ON s.id = unique_ids.id;

-- Insert only valid credit records (IDs that exist in application_record)
INSERT INTO credit_record (id, months_balance, status)
SELECT s.id, s.months_balance, s.status
FROM credit_record_staging s
JOIN application_record a ON s.id = a.id;

-- Clean up: Drop staging tables now that all data has been inserted into real tables
-- Drop raw application and credit records table
DROP TABLE IF EXISTS application_record_staging;
DROP TABLE IF EXISTS credit_record_staging;

-- Drop the view if it already exists
DROP VIEW IF EXISTS credit_data_v0;

-- Create a view that merges application_record and summarized credit_record
CREATE VIEW credit_data_v0 AS
-- Create a credit record summary per customer ID from inserted data
-- Equivalent to: 
--   cred_prep['FLAG_OVERDUE_30D'] = cred_prep['STATUS'].isin(['1','2','3','4','5']).astype(int)
--   cred_prep['MONTHS_RECORD'] = cred_prep['MONTHS_BALANCE'].abs()
--   cred_prep.groupby('ID')[['MONTHS_RECORD', 'FLAG_OVERDUE_30D']].max()
WITH credit_summary AS (
    SELECT
        id,
        MAX(ABS(months_balance)) AS months_record,  -- deepest historical record
        MAX(CASE WHEN status IN ('1', '2', '3', '4', '5') THEN 1 ELSE 0 END) AS flag_overdue_30d
    FROM credit_record
    GROUP BY id
)
-- Merge application_record with credit_summary
-- Equivalent to pandas' merged_df = pd.merge(app_raw, cred_prep, on='ID', how='inner')
SELECT
    a.*,                 -- All columns from application_record (demographics, income, etc.)
    c.months_record,     -- Months of credit history
    c.flag_overdue_30d   -- Overdue flag
FROM application_record a
JOIN credit_summary c ON a.id = c.id;

-- Drop the view if it already exists
DROP VIEW IF EXISTS credit_data_v1;

-- Create a view for current cleaned/transformed state
CREATE VIEW credit_data_v1 AS
SELECT
    id,
    ABS(days_birth) AS days_birth,  -- convert to positive values (age in days)
    CASE 
        WHEN days_employed = 365243 THEN 0   -- Replace 365243 (unemployed placeholder) with 0,
        ELSE ABS(days_employed)              -- otherwise use positive value
    END AS days_employed,
    CASE 
        WHEN code_gender = 'F' THEN 0
        WHEN code_gender = 'M' THEN 1
        ELSE NULL
    END AS flag_gender,
    CASE 
        WHEN flag_own_car = 'Y' THEN 1
        WHEN flag_own_car = 'N' THEN 0
        ELSE NULL
    END AS flag_car,
    CASE 
        WHEN flag_own_realty = 'Y' THEN 1
        WHEN flag_own_realty = 'N' THEN 0
        ELSE NULL
    END AS flag_realty,
    -- Drop these columns by excluding them from SELECT:
    -- FLAG_MOBIL, CODE_GENDER, FLAG_OWN_CAR, FLAG_OWN_REALTY, OCCUPATION_TYPE
    -- Retain remaining columns
    cnt_children,
    amt_income_total,
    name_income_type,
    name_education_type,
    name_family_status,
    name_housing_type,
    flag_work_phone,
    flag_phone,
    flag_email,
    cnt_fam_members,
    months_record,
    flag_overdue_30d
FROM credit_data_v0;

-- Drop the view if it already exists
DROP VIEW IF EXISTS credit_data_v2;

-- Create a view with outlier handling applied to key columns
CREATE VIEW credit_data_v2 AS
SELECT
    id,
    days_birth,
    days_employed,
    flag_gender,
    flag_car,
    flag_realty,
    -- Cap number of children at 5 to reduce skew
    LEAST(cnt_children, 5) AS cnt_children,
    -- Cap income at 1,000,000 to avoid extreme outliers
    LEAST(amt_income_total, 1000000) AS amt_income_total,
    name_income_type,
    name_education_type,
    name_family_status,
    name_housing_type,
    flag_work_phone,
    flag_phone,
    flag_email,
    -- Cap family size at 7 (values above are rare and likely anomalies)
    LEAST(cnt_fam_members, 7) AS cnt_fam_members,
    months_record,
    flag_overdue_30d
FROM credit_data_v1;

-- Drop the final table if it already exists
DROP TABLE IF EXISTS credit_data_prepared;

-- Create the real table from credit_data_v2
-- Columns reordered to match final structure requirement
CREATE TABLE credit_data_prepared AS
SELECT
    id,
    cnt_children,
    amt_income_total,
    name_income_type,
    name_education_type,
    name_family_status,
    name_housing_type,
    days_birth,
    days_employed,
    flag_work_phone,
    flag_phone,
    flag_email,
    cnt_fam_members,
    months_record,
    flag_overdue_30d,
    flag_gender,
    flag_car,
    flag_realty
FROM credit_data_v2  -- Source view that contains all transformation logic
ORDER BY id;         -- Sort rows by ID for consistent output