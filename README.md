# Credit Card Approval (SQL Wrangling Project)

This project processes and prepares credit card approval data using PostgreSQL. It follows a staging-based ETL approach to load raw CSVs, clean and transform the data, and output structured datasets. The SQL logic is supported by pandas-based exploratory wrangling in a Jupyter notebook.

## Project Structure

```
credit-card-approval/
├── data/                         # Contains raw CSV files (excluded from Git)
│   ├── application_record.csv
│   └── credit_record.csv
│
├── output/
│   └── credit_data_prepared.csv # Cleaned data output from SQL or pandas
│
├── notebooks/
│   └── credit_card_approval_wrangling.ipynb
│
├── sql/
│   ├── 01_schema.sql            # Creates real + staging tables
│   └── 02_wrangling.sql         # Cleans and inserts into real tables
│
├── requirements.txt             # Python packages for notebook
├── .gitignore                   # Prevents raw data and cache files from being tracked
└── README.md                    # Project documentation
```

## Dataset

This project uses the publicly available Credit Card Approval dataset from Kaggle.

Download from:  
https://www.kaggle.com/datasets/rikdifos/credit-card-approval-prediction

After downloading, place the following files inside the `data/` folder:

```
credit-card-approval/
└── data/
    ├── application_record.csv
    └── credit_record.csv
```

## SQL Setup Instructions

### 1. Create the PostgreSQL Database

Using SQL:

```sql
CREATE DATABASE credit_card_approval;
```

Or from the terminal:

```bash
createdb -U postgres credit_card_approval
```

### 2. Create Schema and Tables (Real + Staging)

```bash
psql -U postgres -d credit_card_approval -f sql/01_schema.sql
```

### 3. Load Raw CSVs into Staging Tables

```bash
psql -U postgres -d credit_card_approval
```

Inside the `psql` prompt:

```sql
\copy application_record_staging FROM 'data/application_record.csv' WITH (FORMAT csv, HEADER true);
\copy credit_record_staging FROM 'data/credit_record.csv' WITH (FORMAT csv, HEADER true);
```

### 4. Run Wrangling Script

```bash
psql -U postgres -d credit_card_approval -f sql/02_wrangling.sql
```

This script will:

- Clean and deduplicate the staging data
- Insert structured records into `application_record` and `credit_record` tables

## Python Environment (Optional)

To run the Jupyter notebook or replicate pandas-based wrangling locally:

### 1. Create and Activate a Virtual Environment

```bash
python -m venv .venv
.venv\Scripts\activate
```

### 2. Install Requirements

```bash
pip install -r requirements.txt
```

This installs:

- `pandas`, `numpy` for wrangling
- `matplotlib`, `seaborn` for visualization
- (Optional) `notebook` or `jupyterlab` if running `.ipynb` locally

## Author

Developed by Rangsi Kayana.  
This project demonstrates structured data wrangling using both SQL and pandas, following best practices in data preparation.
