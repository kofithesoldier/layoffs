create  database layoffsDB;
SELECT * FROM LAYOFFS;
select count(*)
from layoffs;

---Data Cleaning

--1. create a staging table
SELECT TOP 0 *
INTO dbo.layoffs_staging
FROM layoffs;

select * from layoffs_staging;

insert layoffs_staging
select * 
from layoffs;



--2.  find duplicates and how many times they appear
with duplicate_CTE AS
(
select *,
       row_number() over ( partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by(select null)) as rn
from layoffs_staging
)
select * from duplicate_CTE
where rn>1;

--3 Deleting Duplicates
with duplicate_CTE AS
(
select *,
       row_number() over ( partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by(select null)) as rn
from layoffs_staging
)
Delete from duplicate_CTE
where rn>1;

-- checking if all duplicates have been successfully deleted                       
select company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions,
       count(*) as duplicate_count
from layoffs_staging
group by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions
having count(*) > 1
order by duplicate_count desc;

--Trim spaces and normalize case
update layoffs_staging
set
   company=UPPER(LTRIM(RTRIM(company))),
   location=UPPER(LTRIM(RTRIM(location))),
   industry=UPPER(LTRIM(RTRIM(industry))),
   stage=UPPER(LTRIM(RTRIM(stage))),
   country=UPPER(LTRIM(RTRIM(country)));

-- Modifying columns- standardizing columns
update layoffs_staging
set company='PAID'
WHERE COMPANY='#PAID';

update layoffs_staging
set company='OPEN'
WHERE COMPANY='&OPEN';

update layoffs_staging
set industry= 'CRYPTO'
WHERE industry like '%CRYPTO%';

   select * from layoffs_staging;
   select distinct industry from layoffs_staging;

-- Cleaning numeric columns

UPDATE dbo.layoffs_staging
SET total_laid_off = TRY_CONVERT(INT, REPLACE(total_laid_off, ',', ''))
WHERE total_laid_off IS NOT NULL;

UPDATE dbo.layoffs_staging
SET funds_raised_millions = TRY_CONVERT(FLOAT, REPLACE(REPLACE(funds_raised_millions, ',', ''), '$', ''))
WHERE funds_raised_millions IS NOT NULL;

UPDATE dbo.layoffs_staging
SET percentage_laid_off = TRY_CONVERT(FLOAT, REPLACE(percentage_laid_off, '%', ''))
WHERE percentage_laid_off IS NOT NULL;

-- cleaning the date column:
--Added a new column named cleaned_date
alter table layoffs_staging
add cleaned_date DATE NULL;

-- copied the data in the old date column to the new cleaned_date column and coverted the data type to DATE
update layoffs_staging
set cleaned_date =TRY_CONVERT (DATE,[date]);

--Dropped/deleted the old date column
alter table layoffs_staging
Drop column [date];

--Renamed the new cleaned_date column to the old name-Date
Exec sp_rename 'dbo.layoffs_staging.cleaned_date', 'date','column';
select * from layoffs_staging;

-- rearranged the table back to its original structure 
alter table layoffs_staging
add funds float;
update layoffs_staging
set funds = funds_raised_millions;

alter table layoffs_staging
drop column funds_raised_millions;

Exec sp_rename 'dbo.layoffs_staging.funds', 'funds_raised_millions','column';

--Finding missing nulls
select * from layoffs_staging
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoffs_staging
where industry is null
or industry=' ';

select distinct company
from layoffs_staging;

select * 
from layoffs_staging 
where company='AIRBNB'

UPDATE layoffs_staging
SET Industry ='TRAVEL'
WHERE company ='AIRBNB';

UPDATE s
SET s.industry = c.industry
FROM dbo.layoffs_staging s
INNER JOIN (
    SELECT company, MAX(industry) AS industry
    FROM dbo.layoffs_staging
    WHERE industry IS NOT NULL
    GROUP BY company
) c
    ON s.company = c.company
WHERE s.industry IS NULL;

select company, industry
from layoffs_staging
where industry ='other';

select company, industry
from layoffs_staging
where industry='null';

select company, industry
from layoffs_staging
where company LIKE '%INTERACTIVE%';

UPDATE layoffs_staging
set industry ='OTHER'
where company ='Bally''s Interactive';

SELECT company,location,industry,country,stage
FROM layoffs_staging
where country is null
or company is null
or location is null
or industry is null
or stage is null;

-- I decided to leave the nulls as they are in the numeric columns because :
-- it is analytically sound, missing value has meaning, want to preserve the data integrity and i am still exploring the data.


