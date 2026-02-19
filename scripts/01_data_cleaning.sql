/*
====================================================================
Project     : World Layoffs – Data Cleaning
Database    : world_layoffs
Source      : layoffs (raw table)
Clean Table : layoffs_staging2
Period      : 2020–2023
Author      : Abhijith P
SQL Version : MySQL 8+
Purpose     : Simulate real-world ETL data cleaning workflow
====================================================================
*/

USE world_layoffs;

-- ================================================================
-- STEP 0: INITIAL DATA VALIDATION
-- PURPOSE: Understand raw dataset size before transformation
-- ================================================================

SELECT COUNT(*) AS raw_row_count
FROM layoffs;

-- ================================================================
-- STEP 1: CREATE STAGING TABLE
-- PURPOSE: Preserve raw data integrity
-- ================================================================

DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- ================================================================
-- STEP 2: REMOVE DUPLICATES
-- PURPOSE: Eliminate duplicate records using business key columns
-- ================================================================

DROP TABLE IF EXISTS layoffs_staging2;

CREATE TABLE layoffs_staging2 AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry,
                            total_laid_off, percentage_laid_off,
                            `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
) AS deduplicated
WHERE row_num = 1;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Validation after deduplication
SELECT COUNT(*) AS row_count_after_dedup
FROM layoffs_staging2;

-- ================================================================
-- STEP 3: STANDARDIZE DATA
-- PURPOSE: Ensure consistency in text, dates, and categorical values
-- ================================================================

START TRANSACTION;

-- 3.1 Trim whitespace in company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- 3.2 Standardize industry values
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 3.3 Standardize country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 3.4 Convert date column from TEXT to DATE
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

COMMIT;

-- ================================================================
-- STEP 4: HANDLE NULL AND BLANK VALUES
-- PURPOSE: Improve data completeness and consistency
-- ================================================================

-- 4.1 Replace blank industry values with NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry IS NOT NULL
  AND TRIM(industry) = '';

-- 4.2 Populate missing industry values using self-join
UPDATE layoffs_staging2 t1
JOIN (
    SELECT company, industry
    FROM layoffs_staging2
    WHERE industry IS NOT NULL
) t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL;

-- 4.3 Standardize unknown stage values
UPDATE layoffs_staging2
SET stage = NULL
WHERE stage LIKE '%Unknown%';

-- ================================================================
-- STEP 5: REMOVE IRRELEVANT ROWS
-- PURPOSE: Remove records lacking layoff information
-- ================================================================

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- ================================================================
-- STEP 6: DATA QUALITY VALIDATION
-- PURPOSE: Final verification checks
-- ================================================================

-- Check remaining NULL industries
SELECT COUNT(*) AS remaining_null_industry
FROM layoffs_staging2
WHERE industry IS NULL;

-- Check date range
SELECT MIN(`date`) AS min_date,
       MAX(`date`) AS max_date
FROM layoffs_staging2;

-- Final cleaned row count
SELECT COUNT(*) AS final_row_count
FROM layoffs_staging2;

-- ================================================================
-- DATA CLEANING SUMMARY
-- ================================================================
/*
1. Created a staging table to preserve raw data integrity.
2. Removed duplicate records (2,361 → 1,995 rows) using window functions.
3. Standardized categorical values for consistency.
4. Converted date column from TEXT to proper DATE format.
5. Handled missing values (blank → NULL, populated industry via self-join).
6. Removed records lacking layoff metrics.
7. Applied transaction control to ensure safe transformations.
*/

-- ================================================================
-- DATA CLEANING COMPLETE
-- Cleaned Table: layoffs_staging2
-- ================================================================
