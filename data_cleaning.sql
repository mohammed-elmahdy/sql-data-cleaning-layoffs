-- =========================================
-- Project: Data Cleaning - Layoffs Dataset
-- Author: Mohammed Elmahdy
-- Date: [2026-03-24]
-- Description: Cleaning and preparing raw layoffs data for analysis
-- =========================================

-- =========================================
-- 1. Inspect Raw Data
-- =========================================

-- Preview the Dataset
SELECT * FROM layoffs;

-- Checked total rows
SELECT COUNT(*) AS total_rows
FROM layoffs;

-- =========================================
-- 2. Create Staging Table
-- =========================================

-- Created a copy to avoid modifying raw data
CREATE TABLE layoffs_staging
AS SELECT * FROM layoffs;

-- Checked the table
SELECT * FROM layoffs_staging;

-- =========================================
-- 3. Remove Duplicates
-- =========================================

-- Identified duplicates
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY company) AS row_num
FROM layoffs_staging;

-- Created CTE to filter out duplicate rows
WITH duplicates AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY company) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicates 
WHERE row_num > 1;

-- Randomly checked company 'Casper' to see if entries qualify as duplicates
SELECT * FROM layoffs_staging
WHERE company = 'casper';

-- Created new staging table with extra column (row_num) to use for detecting duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int DEFAULT NULL
);

-- Added all columns from 'layoffs_staging' table + window function (row_num) for detecting duplicates 
INSERT INTO layoffs_staging2 
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Checked duplicates again from new table to see if rows were transfered correctly 
SELECT * FROM layoffs_staging2
WHERE row_num > 1;

-- Deleted duplicate rows
DELETE FROM layoffs_staging2
WHERE row_num >= 2;

-- =========================================
-- 4. Standardize Data
-- =========================================

-- Trimmed 'company' column
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Checked industry column for blank/null values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Checked companies with 'blank' industry entries to see if they can be filled.
SELECT * FROM layoffs_staging2
WHERE company LIKE '%airbnb%';

SELECT * FROM layoffs_staging2
WHERE company LIKE '%carvana%';

SELECT * FROM layoffs_staging2
WHERE company LIKE '%juul%';

-- Changed all blank values to NULLs to make it easier when filling data in
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Will populate null values where possible
UPDATE layoffs_staging2 t1 JOIN
layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND
t2.industry IS NOT NULL;

-- Checked again null values, only 1 company has null value without a populated row to populate this null value
SELECT * FROM layoffs_staging2
WHERE industry IS NULL;

-- Detected inconsistent industry sector names (Crypt, Cryto Curreny, CryptoCurrency)
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- Standardized industry name
UPDATE layoffs_staging2
SET industry = CASE
WHEN lower(industry) LIKE '%crypto%' THEN 'Crypto Currency'
ELSE industry
END;

-- Confirmed changed was made
SELECT DISTINCT industry FROM layoffs_staging2
ORDER BY industry;

-- Standardized date format to yyyy-mm--dd
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE (`date`, '%m/%d/%Y');

-- Changed `date` column type to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Detected and updated inconsistent country name for united states, some have "United States." with a period
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- =========================================
-- 5. Handle NULL values
-- =========================================

-- Checking which rows have NULL values for both 'total_laid_off' and 'percentage_laid_off'
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND 
percentage_laid_off IS NULL;

-- Deleted useless entries
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND 
percentage_laid_off IS NULL;

-- =========================================
-- 6. Remove unwanted columns
-- =========================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- =========================================
-- 7. Final Cleaned Data Check
-- =========================================

SELECT * FROM layoffs_staging2;

-- =========================================
-- 8. Create Final Table
-- =========================================

CREATE TABLE layoffs_cleaned
AS SELECT * FROM layoffs_staging2