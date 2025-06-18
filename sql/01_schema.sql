-- Stores customer demographic and financial profile
CREATE TABLE application_record (
    id BIGINT PRIMARY KEY,                           -- Unique customer ID
    code_gender VARCHAR(10) NOT NULL,                -- Gender ('M' or 'F')
    flag_own_car CHAR(1) NOT NULL,                   -- Owns a car ('Y' or 'N')
    flag_own_realty CHAR(1) NOT NULL,                -- Owns real estate ('Y' or 'N')
    cnt_children INTEGER NOT NULL,                   -- Number of children
    amt_income_total NUMERIC(15, 2) NOT NULL,        -- Annual income
    name_income_type TEXT NOT NULL,                  -- Type of income (e.g., 'Working', 'Pensioner')
    name_education_type TEXT NOT NULL,               -- Education level
    name_family_status TEXT NOT NULL,                -- Marital status
    name_housing_type TEXT NOT NULL,                 -- Housing type (e.g., 'Rented', 'With parents')
    days_birth INTEGER NOT NULL,                     -- Age in days (negative number)
    days_employed INTEGER NOT NULL,                  -- Employment length in days (negative = currently employed)
    flag_mobil SMALLINT NOT NULL,                    -- Has a mobile phone (1 or 0)
    flag_work_phone SMALLINT NOT NULL,               -- Has a work phone (1 or 0)
    flag_phone SMALLINT NOT NULL,                    -- Has a home phone (1 or 0)
    flag_email SMALLINT NOT NULL,                    -- Has an email address (1 or 0)
    occupation_type TEXT,                            -- Job type (nullable)
    cnt_fam_members NUMERIC(4, 1) NOT NULL           -- Number of family members
);

-- Stores monthly credit history for each customer
CREATE TABLE credit_record (
    id BIGINT NOT NULL,                              -- Customer ID (foreign key)
    months_balance INTEGER NOT NULL,                 -- Months before current (0 = current, -1 = previous, etc.)
    status VARCHAR(1) NOT NULL,                      -- Payment status (0–5, C = paid off, X = no loan)
    FOREIGN KEY (id) REFERENCES application_record(id)
);

-- Load data into application_record
COPY application_record
FROM 'C:\Users\LEGION 5\dev\repos\credit-card-approval\data\application_record.csv'
DELIMITER ',' CSV HEADER;

-- Load data into credit_record
COPY credit_record
FROM 'C:\Users\LEGION 5\dev\repos\credit-card-approval\data\credit_record.csv'
DELIMITER ',' CSV HEADER;