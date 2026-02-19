# World Layoffs Data Analysis (2020–2023)

## Executive Summary

This project performs end-to-end data cleaning and exploratory data analysis (EDA) on a global layoffs dataset using MySQL.

The analysis covers **383,659 layoffs across 1,995 recorded events (2020–2023)** and identifies structural workforce correction trends following the COVID-19 pandemic.

---

## Problem Statement

Between 2020 and 2023, global markets experienced significant workforce reductions.

This project aims to:

- Analyze layoff trends over time  
- Identify the most impacted companies, industries, and countries  
- Measure year-over-year changes  
- Detect structural economic patterns post-pandemic  
- Quantify overall workforce impact  

---

## Project Structure

```
world-layoffs-sql-analysis/
│
├── data/
│   ├── cleaned_data
│         └── layoffs_staging2.csv
│   ├── raw_data
│         └── layoffs.csv
│
├── scripts/
│   ├── 01_data_cleaning.sql
│   ├── 02_exploratory_data_analysis.sql
│   └── testing_queries.sql
│
└── README.md
```

---


---

# Data Cleaning & Preparation

The raw dataset contained duplicate records, inconsistent categorical values, blank fields, and incorrect data types.

## Cleaning Actions Performed

- Created a staging table to preserve raw dataset integrity  
- Removed duplicate records (2,361 → 1,995 rows) using ROW_NUMBER()  
- Standardized categorical fields (industry, country, stage)  
- Converted `date` column from TEXT to proper DATE data type  
- Replaced blank values with NULL  
- Populated missing industry values using self-join logic  
- Removed records lacking layoff metrics  
- Applied transaction control to ensure safe transformations  

Result: A clean, analysis-ready dataset with validated metrics and consistent structure.

---

# Dataset Overview

- Total records: 1,995 layoff events  
- Total employees laid off: 383,659  
- Time period: March 11, 2020 – March 6, 2023  
- Total columns: 9  

---

# Key Insights

## Largest Single Layoff Event

- Google (2023): 12,000 employees  

## Complete Company Shutdowns

- 116 companies recorded 100% workforce layoffs  

## Company with Highest Total Layoffs

- Amazon: 18,150 employees  

## Most Impacted Industry

- Consumer industry: 45,182 layoffs (11.78% of total)

Industries repeatedly impacted:

- Transportation  
- Travel  
- Finance  
- Retail  
- Food  

## Most Impacted Country

- United States: 256,559 layoffs  

## Most Severe Year

- 2022: 160,661 layoffs  

Year-over-Year Change:

- 2020 → 2021: -65,175 (stabilization phase)  
- 2021 → 2022: +144,838 (major correction phase)  

## Early 2023 Spike

- January 2023 alone: 84,714 layoffs  
- Approximately 78% of total 2022 layoffs  

---

# Advanced Analysis Performed

- Rolling monthly cumulative totals  
- 3-month moving average  
- Year-over-year growth analysis  
- Top 5 companies per year  
- Top 5 industries per year  
- Industry percentage contribution  

---

# Economic Interpretation

The data reflects three distinct economic phases:

Phase 1 — Pandemic Shock (2020)  
Initial disruption due to global lockdowns.

Phase 2 — Stabilization (2021)  
Temporary recovery as markets adjusted.

Phase 3 — Structural Correction (2022–2023)  
Sharp increase in layoffs driven by:
- Pandemic-era overhiring  
- Technology valuation corrections  
- Funding slowdowns  
- Macroeconomic tightening  

The 2022–2023 wave appears structural rather than purely pandemic-driven.

---

# Skills Demonstrated

- SQL Data Cleaning  
- Window Functions (ROW_NUMBER, LAG, DENSE_RANK)  
- Common Table Expressions (CTEs)  
- Time Series Analysis  
- Rolling Aggregations  
- Moving Averages  
- Analytical Interpretation  
- Business Insight Extraction  

---

# Author

Abhijith P  
SQL | Data Analysis | Exploratory Projects  

