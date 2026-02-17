/* ============================================================
   WORLD LAYOFFS DATA CLEANING PROJECT
   Database: world_layoffs
   Description: Cleaning raw layoffs dataset for analysis
   ============================================================ */

USE world_layoffs;

-- ============================================================
-- 1. CREATE STAGING TABLE
-- ============================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- ============================================================
-- 2. REMOVE DUPLICATES
-- ============================================================

-- Identify duplicates using ROW_NUMBER()

CREATE TABLE layoffs_staging2 AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry,
                        total_laid_off, percentage_laid_off,
                        `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Delete duplicate rows

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Remove helper column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ============================================================
-- 3. STANDARDIZE DATA
-- ============================================================

-- Trim whitespace in company names

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry values

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country names

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date column from TEXT to DATE

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ============================================================
-- 4. HANDLE NULL AND BLANK VALUES
-- ============================================================

-- Replace blank industry values with NULL

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing industry values using self join

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Standardize unknown stage values

UPDATE layoffs_staging2
SET stage = NULL
WHERE stage LIKE '%Unknown%';

-- ============================================================
-- 5. REMOVE IRRELEVANT ROWS
-- ============================================================

-- Delete rows where both layoff metrics are NULL

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- ============================================================
-- DATA CLEANING COMPLETE
-- Cleaned table: layoffs_staging2
-- ============================================================
