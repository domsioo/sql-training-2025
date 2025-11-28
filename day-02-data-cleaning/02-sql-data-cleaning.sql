CREATE DATABASE world_layoffs
USE world_layoffs
SELECT * FROM dbo.layoffs

-- Copy data into new table meant for cleaning
SELECT *
INTO layoffs_staging
FROM dbo.layoffs;
GO

SELECT * FROM layoffs_staging

-- 1. Remove Duplicates
-- identify duplicates
;WITH duplicates_cte AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, total_laid_off, percentage_laid_off, date
		ORDER BY (SELECT NULL)
	) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1

-- Check if the CTE is correct. I identified 'Oda' as one of the duplicates

SELECT * FROM layoffs_staging WHERE company = 'Oda'

-- It turns out that Oda actually doesn't have duplicates, I didn't have enough PARTITIONS
-- Oda	Oslo	Food	70	0.18	11/1/2022	Unknown	Sweden	377(HERE)
-- Oda	Oslo	Food	70	0.18	11/1/2022	Unknown	Norway	477(HERE)

-- I need to add more columns to PARTITION BY clause

;WITH duplicates_cte AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY 
			company, location, total_laid_off, 
			percentage_laid_off, date, stage,
			country, funds_raised_millions
		ORDER BY (SELECT NULL)
	) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1

-- Now all rows are identified uniquely, and Oda is no longer there

-- Remove them

;WITH duplicates_cte AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY 
			company, location, total_laid_off, 
			percentage_laid_off, date, stage,
			country, funds_raised_millions
		ORDER BY (SELECT NULL)
	) AS row_num
FROM layoffs_staging
)
DELETE FROM duplicates_cte
WHERE row_num > 1

-- 2. Standarize the Data

SELECT company, TRIM(company)
FROM layoffs_staging

UPDATE layoffs_staging 
SET company = TRIM(company)

SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY 1 

-- I found that crypt has 3 different categories: Crypto, Crypto Currency, and CryptoCurrency
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%'

SELECT DISTINCT industry
FROM layoffs_staging
WHERE industry LIKE '%Crypto%' -- only one unique name now

-- location
SELECT DISTINCT location
FROM layoffs_staging
ORDER BY 1 -- looks good, no changes needed

-- country
SELECT DISTINCT country
FROM layoffs_staging
ORDER BY 1 -- issue found: we have `United States` AND `United States.`

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging
ORDER BY 1 -- now `united states.` is fixed

UPDATE layoffs_staging 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'

-- `date` is an NVARCHAR column - we need it as date for further analysis 
SELECT [date], CONVERT(datetime, [date], 101) 
FROM layoffs_staging
SELECT * FROM layoffs_staging -- there is an error (NULL) here and I need to investigate it

-- I need to fix it in a few steps
-- date column seems to have NULL (as text), not SQL value
-- I will add a new typed, nullable column
ALTER TABLE layoffs_staging
ADD date_dt date NULL

-- populate with clean values
UPDATE layoffs_staging
SET date_dt = TRY_CONVERT(
				date,
				NULLIF(LTRIM(RTRIM([date])), 'NULL'),
				101 -- mm/dd/yyyy
				)

-- Check for stil bad values
SELECT [date], date_dt
FROM layoffs_staging
WHERE date_dt IS NULL
  AND LTRIM(RTRIM([date])) NOT IN ('', 'NULL');

-- Making the new column the main one
ALTER TABLE layoffs_staging
DROP COLUMN [date]

EXEC sp_rename 'layoffs_staging.date_dt', 'date', 'COLUMN';

SELECT * FROM layoffs_staging -- now it works as date

-- Dealing with NULLs
SELECT * 
FROM layoffs_staging
WHERE total_laid_off = 'NULL' -- still not a real NULL but text 'NULL'

-- 3. Null/Blank Values

-- I noticed before that some companies have NULLs or missing industry fields

SELECT * 
FROM layoffs_staging
WHERE industry IS NULL OR industry IN ('', 'NULL')

-- Let's see if we know some info about them from other rows
SELECT *
FROM layoffs_staging 
WHERE company IN ('Airbnb', 'Bally''s Interactive', 'Juul', 'Carvana')
-- I see that Airbnb: Travel, Carvana: Transportation, Juul: Consumer, no info about Bally's

UPDATE layoffs_staging
SET industry =
	CASE
		WHEN company = 'Airbnb' THEN 'Travel'
		WHEN company = 'Carvana' THEN 'Transportation'
		WHEN company = 'Juul' THEN 'Consumer'
		ELSE industry
	END
WHERE industry IS NULL OR industry IN ('', 'NULL')

-- Now only Bally's is left but I don't have more information about them from other rows
-- Perhaps looking them up on the Internet would be the right thing to do
SELECT * 
FROM layoffs_staging
WHERE industry IS NULL OR industry IN ('', 'NULL')

-- Let's also convert the data types of columns: total_laid_off, percentage_laid_off, and funds_raised
UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE LTRIM(RTRIM(total_laid_off)) IN ('', 'NULL')

UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE LTRIM(RTRIM(funds_raised_millions)) IN ('', 'NULL')

UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE LTRIM(RTRIM(total_laid_off)) IN ('', 'NULL')

-- now it's real NULLs
SELECT * 
FROM layoffs_staging

-- They should be now int-able or decimal-able
SELECT DISTINCT total_laid_off
FROM layoffs_staging
WHERE TRY_CONVERT(int, total_laid_off) IS NULL 
AND total_laid_off IS NOT NULL

SELECT DISTINCT percentage_laid_off
FROM layoffs_staging
WHERE TRY_CONVERT(decimal(5,2), percentage_laid_off) IS NULL
	AND percentage_laid_off IS NOT NULL

SELECT DISTINCT funds_raised_millions
FROM layoffs_staging
WHERE TRY_CONVERT(decimal(18,2), funds_raised_millions) IS NULL
  AND funds_raised_millions IS NOT NULL;


-- all of them seem fine
-- I will alter the columns now
ALTER TABLE layoffs_staging
ALTER COLUMN total_laid_off INT NULL

ALTER TABLE layoffs_staging
ALTER COLUMN percentage_laid_off DECIMAL(5,2) NULL

ALTER TABLE layoffs_staging
ALTER COLUMN funds_raised_millions DECIMAL(18,2) NULL

-- 4. Remove Any Columns

SELECT * 
FROM layoffs_staging
WHERE	(total_laid_off = 'NULL' OR total_laid_off = '' OR total_laid_off IS NULL)
		AND
		(percentage_laid_off = 'NULL' OR percentage_laid_off = '' OR percentage_laid_off IS NULL)

-- I identified columns that potentially could have no use based on the further analysis
-- I need to think what I will do with the data in the near future
-- The issue is that these companies have no laid-ofss and no percentage so I don't
-- even know if anyone got laid_off
-- It's important to be confident in knowing whether the data rows should be delted or not
-- In this case I will delete those rows because I won't use them later

DELETE 
FROM layoffs_staging
WHERE	(total_laid_off = 'NULL' OR total_laid_off = '' OR total_laid_off IS NULL)
		AND
		(percentage_laid_off = 'NULL' OR percentage_laid_off = '' OR percentage_laid_off IS NULL)

SELECT * FROM layoffs_staging

-- This wraps up the data cleaning process for this project