# World Layoffs SQL Analysis

## Project Overview

This project performs end-to-end data cleaning and exploratory data analysis (EDA) on a global layoffs dataset using MySQL.

The objective was to transform raw, inconsistent data into a structured, analysis-ready dataset and uncover meaningful trends across companies, industries, countries, and time.

---

## Project Structure

```
world-layoffs-sql-analysis/
│
├── data/
│   └── layoffs.csv
│
├── scripts/
│   ├── 01_data_cleaning.sql
│   ├── 02_exploratory_data_analysis.sql
│   └── testing_queries.sql
│
└── README.md
```


---

## Phase 1: Data Cleaning

Performed structured data cleaning including:

- Created staging tables to preserve raw data
- Removed duplicate records using ROW_NUMBER()
- Standardized inconsistent values (company, industry, country)
- Converted text-based dates to DATE format
- Handled missing and blank values using self-joins
- Removed rows with no analytical relevance
- Validated cleaning using dedicated testing queries

The cleaned dataset is stored in:

layoffs_staging2

---

## Phase 2: Exploratory Data Analysis (EDA)

Key analyses performed:

- Maximum single layoff event
- Total layoffs across dataset
- Layoffs by company
- Layoffs by industry
- Layoffs by country
- Layoffs by company stage
- Yearly layoff trends
- Monthly layoff trends
- Rolling cumulative layoffs
- Top 5 companies per year using DENSE_RANK()

---

## Tools and Concepts Used

- MySQL
- CTEs
- Window Functions (ROW_NUMBER, DENSE_RANK)
- Aggregate Functions
- Date Functions (YEAR, DATE_FORMAT)
- Data Validation Techniques

---

## Key Outcomes

- Cleaned and structured dataset ready for advanced analysis
- Identified trends in global layoffs across industries and time
- Demonstrated a complete SQL data workflow:
  Raw Data → Cleaning → Validation → Analysis

---

## Dataset

- Global layoffs dataset (CSV format)
- Stored in the /data directory
- Used for educational and analytical purposes

---

## Author

Abhijith P
SQL | Data Analytics
