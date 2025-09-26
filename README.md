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

  ## Dataset
  The dataset contains the following columns:

|Column                  | Description                      |
|                        |
|                         |
| ----------------------- | -------------------------------- |
| `company`               | Company name                     |
| `location`              | City or region of the company    |
| `industry`              | Industry sector                  |
| `total_laid_off`        | Number of employees laid off     |
| `percentage_laid_off`   | Percentage of workforce laid off |
| `date`                  | Date of layoff event             |
| `stage`                 | Stage of reporting               |
| `country`               | Country of the company           |
| `funds_raised_millions` | Total funds raised in millions   |

## Database Setup

  **Create a database:**
```sql
   CREATE DATABASE layoffsDB;
GO
```
***Use the database:**
```sql
  USE layoffsDB;
GO
```
 **Staging Table Creation**
Instead of manually defining the table, a staging table was created from the original table using SELECT INTO:
-- Create an empty staging table with the same structure as the original
```sql
SELECT TOP 0 *
INTO dbo.layoffs_staging
FROM layoffs;
``

-- Verify table creation
```sql
SELECT * FROM layoffs_staging;
```

-- Copy all data into the staging table
```sql
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;
```
Purpose: The staging table allows safe data cleaning and transformation without altering the original dataset.

 ## Data Cleaning
**1. Remove Duplicate Rows**
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
```
Purpose: Keep only unique rows.

**2.Handle Nulls in Text Columns**
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
```
Purpose: Fill missing industry values from other rows of the same company.


