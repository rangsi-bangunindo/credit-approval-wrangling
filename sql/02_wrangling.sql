-- 02_wrangling.sql

-- Clear the main table before inserting deduplicated data
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