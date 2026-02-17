/* ============================================================
   WORLD LAYOFFS - DATA VALIDATION & TESTING QUERIES
   Purpose: Validate cleaning process and data integrity
   ============================================================ */

USE world_layoffs;

-- ============================================================
-- 1. ROW COUNT VALIDATION
-- ============================================================

-- Row count BEFORE cleaning
SELECT COUNT(*) AS rows_before_cleaning
FROM layoffs;

-- Row count AFTER cleaning
SELECT COUNT(*) AS rows_after_cleaning
FROM layoffs_staging2;

-- Total rows removed
SELECT 
    (SELECT COUNT(*) FROM layoffs) -
    (SELECT COUNT(*) FROM layoffs_staging2) 
    AS total_rows_removed;


-- ============================================================
-- 2. DUPLICATE CHECK
-- ============================================================

-- Ensure no duplicate records remain

SELECT company, location, industry,
       total_laid_off, percentage_laid_off,
       `date`, stage, country, funds_raised_millions,
       COUNT(*) AS duplicate_count
FROM layoffs_staging2
GROUP BY company, location, industry,
         total_laid_off, percentage_laid_off,
         `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. NULL VALUE VALIDATION
-- ============================================================

-- Missing industry values
SELECT COUNT(*) AS null_industry
FROM layoffs_staging2
WHERE industry IS NULL;

-- Missing dates
SELECT COUNT(*) AS null_dates
FROM layoffs_staging2
WHERE `date` IS NULL;

-- Rows with no layoff data
SELECT COUNT(*) AS null_layoff_data
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ============================================================
-- 4. DATA TYPE & RANGE CHECK
-- ============================================================

-- Date range validation
SELECT MIN(`date`) AS earliest_date,
       MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- Total layoffs check
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2;


-- ============================================================
-- 5. STANDARDIZATION VALIDATION
-- ============================================================

-- Distinct industries
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- Distinct countries
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Distinct stages
SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;


-- ============================================================
-- TESTING COMPLETE
-- Data verified and ready for exploratory analysis
-- ============================================================
