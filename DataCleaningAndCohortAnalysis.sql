--Cleaning Data

--Total Records 541909

SELECT *
FROM [dbo].[online_retail];

--135080 Records have no customerID

SELECT *
FROM [dbo].[online_retail]
WHERE CustomerID IS NULL;

--406829 Records have customerID

SELECT *
FROM [dbo].[online_retail]
WHERE CustomerID IS NOT NULL;

--Creating CTE for the usable records

WITH online_retail AS
(
	SELECT 
		InvoiceNo,
		StockCode,
		Description,
		Quantity,
		InvoiceDate,
		UnitPrice,
		CustomerID,
		Country
	FROM [dbo].[online_retail]
	WHERE CustomerID IS NOT NULL
)
, quantity_unit_price AS
(
	--397884 Records with quantity and Unit price
	SELECT * 
	FROM online_retail
	WHERE Quantity > 0 AND UnitPrice > 0
)
, dup_check AS
(

	--Duplicate check
	SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY InvoiceNo, StockCode, Quantity ORDER BY InvoiceDate) AS dup_flag
	FROM quantity_unit_price
)
--392669 Records of clean data
--5215 duplicate records
SELECT *
INTO #online_retail_main
FROM dup_check
WHERE dup_flag = 1

--Clean Data
--Begin Cohort Analysis

SELECT *
FROM #online_retail_main

--Unique Identifier (CustomerID)
--Initial Start Date (First Invoice Date)
--Revenue Data

SELECT
	CustomerID,
	MIN(InvoiceDate) AS first_purchase_date,
	DATEFROMPARTS(year(MIN(InvoiceDate)),month(MIN(InvoiceDate)),1) AS Cohort_Date
INTO #cohort
FROM #online_retail_main
GROUP BY CustomerID

SELECT *
FROM #cohort

--Create Cohort Index

SELECT
	mmm.*,
	cohort_index = year_diff * 12 + month_diff + 1
INTO #cohort_retention
FROM
	(
	SELECT
		mm.*,
		year_diff = invoice_year - cohort_year,
		month_diff = invoice_month - cohort_month
	FROM
		(
		SELECT 
			m.*,
			c.Cohort_Date,
			year(m.InvoiceDate) AS invoice_year,
			month(m.InvoiceDate) AS invoice_month,
			year(c.Cohort_Date) AS cohort_year,
			month(c.Cohort_Date) AS cohort_month
		FROM #online_retail_main m
		LEFT JOIN #cohort c
			ON m.CustomerID = c.CustomerID
		) AS mm
	) AS mmm;
