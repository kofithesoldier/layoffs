--Exploratory Data Analysis(EDA)

select * from layoffs_staging;

--BASIC EDA:
--Q.1. How many total rows are there in the cleaned layoffs_staging table, and how many unique companies are represented?

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT company) AS unique_companies
FROM dbo.layoffs_staging;

--Q.2. What is the total number of layoffs (total_laid_off) in the dataset, and what is the average number of layoffs per company?

SELECT * FROM layoffs_staging;

--the total number of layoffs (total_laid_off) in the dataset
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging;


--the average number of layoffs per company
SELECT AVG(total_laid_off_per_company) AS avg_layoffs_per_company
FROM (
    SELECT company, SUM(total_laid_off) AS total_laid_off_per_company
    FROM dbo.layoffs_staging
    GROUP BY company
) AS company_totals;

--Q.3. Which industry has experienced the highest total layoffs?
SELECT * FROM layoffs_staging;
select top 1
      industry,
      sum(total_laid_off) as total_layoffs
from layoffs_staging
group by industry
order by 2  desc;

--Q.4. What is the average percentage of employees laid off (percentage_laid_off) per company?
Select * from layoffs_staging;

select 
      company,
      avg(percentage_laid_off) as avg_percentage_layoffs
from layoffs_staging
group by company;

--Q.5.Which location has experienced the highest total layoffs?
select top 1
      location,
      sum(total_laid_off) as total_layoffs
from layoffs_staging
group by location
order by 2 desc;

--Q.6 Find the earliest and latest layoff dates .

select * from layoffs_staging;

SELECT 
    MIN([date]) AS earliest_layoff_date,
    MAX([date]) AS latest_layoff_date
FROM dbo.layoffs_staging;

--INTERMEDIATE EDA:

--Q.1 Which 3 companies have laid off the most employees in total?
select * from layoffs_staging;
select top 3
     company,
     sum(total_laid_off) as total_layoffs
from layoffs_staging
group by company
order by 2 desc;

--Q.2.  Which industry has the highest average percentage of employees laid off?
select top 1
      industry,
      avg(percentage_laid_off) as avg_percentage
from layoffs_staging
group by industry
order by 2 desc;

-- Q.3. Which company raised the most funds (funds_raised_millions)?
Select * from layoffs_staging;
select top 1
      company,
       sum(funds_raised_millions) as most_funds
from layoffs_staging
group by company
order by 2 desc;

--Q.4.Which month (ignoring year) saw the highest total layoffs across all companies?
select * from layoffs_staging;

SELECT TOP 1
       DATENAME(month,[date]) AS month_name,
       SUM(total_laid_off) AS total_layoffs
FROM dbo.layoffs_staging
GROUP BY DATENAME(month,[date]), MONTH([date])
ORDER BY total_layoffs DESC;

--Q.5. Which year had the highest total layoffs?
Select top 1
      datepart(year,[date]) as year_name,
      sum(total_laid_off) as total_layoffs
from layoffs_staging
group by datepart(year,[date])
order by 2 desc;

--Q.6. Which country had the highest average percentage of layoffs (percentage_laid_off)?
select * from layoffs_staging;
select top 1
      country,
      round(avg(percentage_laid_off),2)as avg_percentage_layoffs
from layoffs_staging
group by country
order by 2 desc;


--ADVANCED EDA:

--Q.1. Which company had the single largest layoff event (highest total_laid_off in one row)?
select * from layoffs_staging;

select top 1 *
from layoffs_staging
order by total_laid_off desc;

--Q.2. Which  5 companies have a high number of layoffs relative to the funds they raised?
SELECT TOP 5
       company,
       SUM(total_laid_off) AS total_layoffs,
       SUM(funds_raised_millions) AS total_funds,
       CASE 
           WHEN SUM(funds_raised_millions) = 0 THEN NULL
           ELSE ROUND(SUM(total_laid_off) / SUM(funds_raised_millions),2)
       END AS layoffs_per_million
FROM dbo.layoffs_staging
GROUP BY company
ORDER BY layoffs_per_million DESC;

--Q.3. Which month and year combination saw the highest total layoffs across all companies?
SELECT TOP 1
       DATENAME(MONTH,[date]) AS month_name,
       DATEPART(YEAR,[date]) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM dbo.layoffs_staging
GROUP BY DATENAME(MONTH,[date]), DATEPART(YEAR,[date]), DATEPART(MONTH,[date])
ORDER BY total_layoffs DESC;

--Q.4.Which companies consistently had layoffs in multiple years (at least 2 different years)?
SELECT 
      company,
      count(distinct DATEPART(YEAR,[date])) as distinct_years
from layoffs_staging
group by company
having count (distinct DATEPART(YEAR,[date]))  >1;

--Q.5. Which companies reported layoffs more than once 
SELECT 
      company,
      count(*) as layoffs_count
from layoffs_staging
group by company
having count(*) >1;

--Q.6.Which companies had the largest single layoff event  and how many employees were laid off?

SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY total_laid_off DESC) AS layoff_rank
    FROM dbo.layoffs_staging
) AS ranked_layoffs
WHERE layoff_rank <= 5;
