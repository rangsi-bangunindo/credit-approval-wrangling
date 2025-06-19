-- 02_wrangling.sql
-- Purpose: Clean, transform the data, and output structured datasets,
-- following best practices in data preparation

TRUNCATE TABLE application_record, credit_record;

-- Insert only unique (non-duplicate) application records from the staging table
-- (IDs that appear exactly once in the staging table)
INSERT INTO application_record (
    id, code_gender, flag_own_car, flag_own_realty, cnt_children, amt_income_total,
    name_income_type, name_education_type, name_family_status, name_housing_type,
    days_birth, days_employed, flag_mobil, flag_work_phone, flag_phone, flag_email,
    occupation_type, cnt_fam_members
)
SELECT
    s.id, s.code_gender, s.flag_own_car, s.flag_own_realty, s.cnt_children, s.amt_income_total,
    s.name_income_type, s.name_education_type, s.name_family_status, s.name_housing_type,
    s.days_birth, s.days_employed, s.flag_mobil, s.flag_work_phone, s.flag_phone, s.flag_email,
    s.occupation_type, s.cnt_fam_members
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

-- Create a base table based on credit record summary
CREATE TABLE credit_data_prepared AS
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