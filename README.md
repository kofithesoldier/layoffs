# layoffs
End-to-end SQL project for cleaning, transforming, and analyzing a company layoffs dataset. Includes staging, data cleaning, handling nulls, duplicates, and advanced exploratory data analysis (EDA) using SQL Server. Ideal for portfolio showcasing SQL and analytical skills.

# Layoffs Data Analysis Project
## Project Overview
This project focuses on cleaning, transforming, and analyzing a layoffs dataset imported from Excel into SQL Server. The dataset contains layoffs information for multiple companies, and the goal is to prepare a clean, structured, and insightful dataset for exploratory data analysis (EDA) and reporting.


# Project Highlights

 * Imported a messy Excel dataset into SQL Server. 

* Created a staging table using SQL (SELECT INTO) to safely clean data.

* Removed duplicates, handled nulls, and standardized text and date fields.

* Performed basic, intermediate, and advanced EDA to uncover insights.

* Prepared queries that demonstrate SQL aggregation, ranking, and window functions.

* Findings can be used for portfolio presentation, reporting, or business analysis.
  
# Skills Demonstrated

* SQL Server data import and staging.

* Data cleaning: duplicates removal, null handling, text and numeric standardization.

* Aggregation and grouping (SUM, AVG, COUNT, DISTINCT).

* Date functions (DATEPART, DATENAME) for trend analysis.

* Window functions (ROW_NUMBER(), RANK()) for advanced analytics.

* Problem-solving and exploratory data analysis (EDA).


## Database Setup

  **Create a database:**
```sql
   CREATE DATABASE layoffsDB;
GO
```
**Use the database:**
```sql
  USE layoffsDB;
GO
```
 **Staging Table Creation**
Instead of manually defining the table, a staging table was created from the original table using SELECT INTO:

```sql
Create an empty staging table with the same structure as the original
SELECT TOP 0 *
INTO dbo.layoffs_staging
FROM layoffs;
```

```sql
Verify table creation
SELECT * FROM layoffs_staging;
```

```sql
 Copy all data into the staging table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

Purpose: The staging table allows safe data cleaning and transformation without altering the original dataset.
```


 ## Data Cleaning
**Remove Duplicate Rows**
```sql
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
               ORDER BY [date]
           ) AS row_num
    FROM dbo.layoffs_staging
)
DELETE FROM CTE WHERE row_num > 1;

Purpose: Keep only unique rows.
```
**Handle Nulls in Text Columns**

```sql
UPDATE s
SET s.industry = t.industry
FROM dbo.layoffs_staging s
JOIN (
    SELECT company, MAX(industry) AS industry
    FROM dbo.layoffs_staging
    WHERE industry IS NOT NULL
    GROUP BY company
) t
ON s.company = t.company
WHERE s.industry IS NULL;

Purpose: Fill missing industry values from other rows of the same company.
```

**Trim spaces and normalize case in Text Columns**
```sql
update layoffs_staging
set
   company=UPPER(LTRIM(RTRIM(company))),
   location=UPPER(LTRIM(RTRIM(location))),
   industry=UPPER(LTRIM(RTRIM(industry))),
   stage=UPPER(LTRIM(RTRIM(stage))),
   country=UPPER(LTRIM(RTRIM(country)));
```

**Modifying columns- standardizing Text columns**
```sql
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
```

**Handle Dates**

Standardized all dates to SQL-recognized formats.
Invalid or null dates can be handled by creating a temporary column, cleaning it, and updating the main date column.

```sql
Added a new column named cleaned_date
alter table layoffs_staging
add cleaned_date DATE NULL;

copied the data in the old date column to the new cleaned_date column and coverted the data type to DATE
update layoffs_staging
set cleaned_date =TRY_CONVERT (DATE,[date]);

Dropped/deleted the old date column
alter table layoffs_staging
Drop column [date];

Renamed the new cleaned_date column to the old name-Date
Exec sp_rename 'dbo.layoffs_staging.cleaned_date', 'date','column';
select * from layoffs_staging;
```
**Cleaning Numeric Columns**

Left nulls in numeric columns (total_laid_off, percentage_laid_off, funds_raised_millions) as-is for analysis purposes.

```sql
UPDATE dbo.layoffs_staging
SET total_laid_off = TRY_CONVERT(INT, REPLACE(total_laid_off, ',', ''))
WHERE total_laid_off IS NOT NULL;

UPDATE dbo.layoffs_staging
SET funds_raised_millions = TRY_CONVERT(FLOAT, REPLACE(REPLACE(funds_raised_millions, ',', ''), '$', ''))
WHERE funds_raised_millions IS NOT NULL;

UPDATE dbo.layoffs_staging
SET percentage_laid_off = TRY_CONVERT(FLOAT, REPLACE(percentage_laid_off, '%', ''))
WHERE percentage_laid_off IS NOT NULL;
```

## Exploratory Data Analysis (EDA)
 # Basic EDA #
 **Q.1. How many total rows are there in the cleaned layoffs_staging table, and how many unique companies are represented?**
```sql
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT company) AS unique_companies
FROM dbo.layoffs_staging;
```

**Q.2. What is the total number of layoffs (total_laid_off) in the dataset, and what is the average number of layoffs per company?**

```sql
SELECT * FROM layoffs_staging;

the total number of layoffs (total_laid_off) in the dataset
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging;


the average number of layoffs per company
SELECT AVG(total_laid_off_per_company) AS avg_layoffs_per_company
FROM (
    SELECT company, SUM(total_laid_off) AS total_laid_off_per_company
    FROM dbo.layoffs_staging
    GROUP BY company
) AS company_totals;
```

**Q.3. Which industry has experienced the highest total layoffs?**
```sql
SELECT * FROM layoffs_staging;
select top 1
      industry,
      sum(total_laid_off) as total_layoffs
from layoffs_staging
group by industry
order by 2  desc;
```

**Q.4. What is the average percentage of employees laid off (percentage_laid_off) per company?**
```sql
Select * from layoffs_staging;

select 
      company,
      avg(percentage_laid_off) as avg_percentage_layoffs
from layoffs_staging
group by company;
```

**Q.5.Which location has experienced the highest total layoffs?**
```sql
select top 1
      location,
      sum(total_laid_off) as total_layoffs
from layoffs_staging
group by location
order by 2 desc;
```

**Q.6 Find the earliest and latest layoff dates.**
```sql
select * from layoffs_staging;

SELECT 
    MIN([date]) AS earliest_layoff_date,
    MAX([date]) AS latest_layoff_date
FROM dbo.layoffs_staging;
```

# Intermediate EDA #
**Q.1 Which 3 companies have laid off the most employees in total?**
```sql
select * from layoffs_staging;
select top 3
     company,
     sum(total_laid_off) as total_layoffs
from layoffs_staging
group by company
order by 2 desc;
```

**Q.2.  Which industry has the highest average percentage of employees laid off?**
```sql
select top 1
      industry,
      avg(percentage_laid_off) as avg_percentage
from layoffs_staging
group by industry
order by 2 desc;
```

**Q.3. Which company raised the most funds (funds_raised_millions)?**
```sql
Select * from layoffs_staging;
select top 1
      company,
       sum(funds_raised_millions) as most_funds
from layoffs_staging
group by company
order by 2 desc;
```

**Q.4.Which month (ignoring year) saw the highest total layoffs across all companies?**
```sql
select * from layoffs_staging;

SELECT TOP 1
       DATENAME(month,[date]) AS month_name,
       SUM(total_laid_off) AS total_layoffs
FROM dbo.layoffs_staging
GROUP BY DATENAME(month,[date]), MONTH([date])
ORDER BY total_layoffs DESC;
```

**Q.5. Which year had the highest total layoffs?**
```sql
Select top 1
      datepart(year,[date]) as year_name,
      sum(total_laid_off) as total_layoffs
from layoffs_staging
group by datepart(year,[date])
order by 2 desc;
```

**Q.6. Which country had the highest average percentage of layoffs (percentage_laid_off)?**
```sql
select * from layoffs_staging;
select top 1
      country,
      round(avg(percentage_laid_off),2)as avg_percentage_layoffs
from layoffs_staging
group by country
order by 2 desc;
```

# Advanced EDA #

**Q.1. Which company had the single largest layoff event (highest total_laid_off in one row)?
```sql
select * from layoffs_staging;

select top 1 *
from layoffs_staging
order by total_laid_off desc;
```

**Q.2. Which  5 companies have a high number of layoffs relative to the funds they raised?
```sql
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
```

**Q.3. Which month and year combination saw the highest total layoffs across all companies?**
```sql
SELECT TOP 1
       DATENAME(MONTH,[date]) AS month_name,
       DATEPART(YEAR,[date]) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM dbo.layoffs_staging
GROUP BY DATENAME(MONTH,[date]), DATEPART(YEAR,[date]), DATEPART(MONTH,[date])
ORDER BY total_layoffs DESC;
```

**Q.4.Which companies consistently had layoffs in multiple years (at least 2 different years)?**
```sql
SELECT 
      company,
      count(distinct DATEPART(YEAR,[date])) as distinct_years
from layoffs_staging
group by company
having count (distinct DATEPART(YEAR,[date]))  >1;
```

**Q.5. Which companies reported layoffs more than once?**
```sql
SELECT 
      company,
      count(*) as layoffs_count
from layoffs_staging
group by company
having count(*) >1;
```

**Q.6.Which companies had the largest single layoff event  and how many employees were laid off?**
```sql
SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY total_laid_off DESC) AS layoff_rank
    FROM dbo.layoffs_staging
) AS ranked_layoffs
WHERE layoff_rank <= 5;
```

## Key Findings

* Certain companies had multiple layoffs over multiple years.

* Industries such as Tech and Travel showed the highest layoffs.

* Some companies laid off a high number of employees relative to the funds raised, indicating financial or operational stress.

* Peak layoffs often occurred in specific months and years, showing temporal trends.

## Report and Conclusion

* The dataset is now clean and ready for analysis.

* Advanced SQL queries enable insights at company, industry, location, and temporal levels.

* Findings can inform business strategy, investment decisions, and workforce planning.

## Suggested Usage

* Use this cleaned dataset for dashboards and visualizations (Power BI, Tableau, or Python).

* Build time-series analysis to track layoffs trends.

* Combine with funding or financial data for predictive insights.

* Serve as a portfolio project demonstrating SQL and data analysis skills.

## Author - Kofi Obeng Nti
This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles.

## Appreciation
Thank you for taking time to read! I hope you found this project helpful and easy to follow .If you have any questions, suggestions, feedback or would like to collaborate ,feel free to open an issue or reach out- I'd love to hear from you!

## Connect with Me
**Email:** kofiobengnti@gmail.com
**Linkedin:** www.linkedin.com/in/kofi-obeng-nti-aa3884140



