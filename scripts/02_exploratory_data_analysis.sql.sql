/*
====================================================================
Project     : World Layoffs – Exploratory Data Analysis (EDA)
Database    : world_layoffs
Dataset     : layoffs_staging2 (Cleaned Table)
Period      : 2020–2023
Author      : Abhijith P
SQL Version : MySQL 8+
Purpose     : Trend, ranking, and contribution analysis of global layoffs
====================================================================
*/

USE world_layoffs;

-- ================================================================
-- SECTION 1: DATA OVERVIEW
-- PURPOSE : Validate dataset structure and coverage
-- ================================================================

-- 1.1 Total Rows
SELECT COUNT(*) AS total_rows
FROM layoffs_staging2;

-- 1.2 Total Columns
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'world_layoffs'
  AND table_name = 'layoffs_staging2';

-- 1.3 Date Range
SELECT 
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_staging2;


-- ================================================================
-- SECTION 2: OVERALL LAYOFF METRICS
-- PURPOSE : Measure scale and extreme values
-- ================================================================

-- 2.1 Total Employees Laid Off
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2;

-- 2.2 Maximum Layoff Event
SELECT 
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 1;

-- 2.3 Companies with 100% Workforce Reduction
SELECT 
    company,
    location,
    industry,
    total_laid_off,
    `date`
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


-- ================================================================
-- SECTION 3: AGGREGATE ANALYSIS
-- PURPOSE : Identify concentration patterns
-- ================================================================

-- 3.1 Total Layoffs by Company
SELECT 
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;

-- 3.2 Total Layoffs by Industry
SELECT 
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 3.3 Total Layoffs by Country
SELECT 
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- 3.4 Total Layoffs by Funding Stage
SELECT 
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- 3.5 Average Layoff Size per Company
SELECT 
    company,
    ROUND(AVG(total_laid_off), 0) AS avg_layoff_size
FROM layoffs_staging2
GROUP BY company
ORDER BY avg_layoff_size DESC;


-- ================================================================
-- SECTION 4: TIME-SERIES ANALYSIS
-- PURPOSE : Identify temporal patterns and volatility
-- ================================================================

-- 4.1 Yearly Layoffs
SELECT 
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS yearly_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY layoff_year
ORDER BY layoff_year;

-- 4.2 Monthly Layoffs
SELECT 
    DATE_FORMAT(`date`, '%Y-%m') AS month_year,
    SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY month_year
ORDER BY month_year;

-- 4.3 Rolling Cumulative Total
WITH monthly_totals AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month_year,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY month_year
)
SELECT 
    month_year,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER (ORDER BY month_year) 
        AS cumulative_layoffs
FROM monthly_totals;

-- 4.4 3-Month Moving Average
WITH monthly_totals AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month_year,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY month_year
)
SELECT 
    month_year,
    monthly_layoffs,
    ROUND(
        AVG(monthly_layoffs) OVER (
            ORDER BY month_year
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 0
    ) AS moving_avg_3_months
FROM monthly_totals;

-- 4.5 Year-over-Year Change
WITH yearly_totals AS (
    SELECT 
        YEAR(`date`) AS layoff_year,
        SUM(total_laid_off) AS yearly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY layoff_year
)
SELECT 
    layoff_year,
    yearly_layoffs,
    yearly_layoffs 
    - LAG(yearly_layoffs) OVER (ORDER BY layoff_year)
        AS yoy_change
FROM yearly_totals
ORDER BY layoff_year;


-- ================================================================
-- SECTION 5: RANKING ANALYSIS
-- PURPOSE : Identify top contributors each year
-- ================================================================

-- 5.1 Top 5 Companies per Year
WITH company_year AS (
    SELECT 
        company,
        YEAR(`date`) AS layoff_year,
        SUM(total_laid_off) AS yearly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY company, layoff_year
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY layoff_year
               ORDER BY yearly_layoffs DESC
           ) AS rank_within_year
    FROM company_year
)
SELECT *
FROM ranked
WHERE rank_within_year <= 5
ORDER BY layoff_year, rank_within_year;

-- 5.2 Top 5 Industries per Year
WITH industry_year AS (
    SELECT 
        industry,
        YEAR(`date`) AS layoff_year,
        SUM(total_laid_off) AS yearly_layoffs
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY industry, layoff_year
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY layoff_year
               ORDER BY yearly_layoffs DESC
           ) AS rank_within_year
    FROM industry_year
)
SELECT *
FROM ranked
WHERE rank_within_year <= 5
ORDER BY layoff_year, rank_within_year;


-- ================================================================
-- SECTION 6: CONTRIBUTION ANALYSIS
-- PURPOSE : Measure proportional impact
-- ================================================================

WITH industry_totals AS (
    SELECT 
        industry,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY industry
)
SELECT 
    industry,
    total_layoffs,
    ROUND(
        total_layoffs * 100.0 
        / SUM(total_layoffs) OVER (),
        2
    ) AS percentage_of_total
FROM industry_totals
ORDER BY total_layoffs DESC;


-- ================================================================
-- EXECUTIVE SUMMARY
-- ================================================================
/*
1. Dataset spans March 2020 to March 2023.
2. 383,659 employees were laid off across 1,995 recorded events.
3. 2022 recorded the highest annual layoffs.
4. January 2023 showed extreme monthly concentration.
5. Large public tech firms contributed heavily to total layoffs.
6. The United States accounted for the majority of workforce reductions.
7. Consumer, Transportation, Travel, Finance, and Retail were repeatedly impacted.
8. 116 companies experienced complete workforce shutdowns.

The data reflects:
• Initial pandemic shock (2020)
• Partial stabilization (2021)
• Structural correction wave (2022)
• Continued contraction into early 2023
*/

-- ================================================================
-- EDA COMPLETE
-- ================================================================
