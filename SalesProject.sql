--Inspecting Data

SELECT * FROM [dbo].[sales_data_sample];

--Checking unique values

SELECT DISTINCT status FROM [dbo].[sales_data_sample]; --Nice to plot
SELECT DISTINCT year_id FROM [dbo].[sales_data_sample];
SELECT DISTINCT PRODUCTLINE FROM [dbo].[sales_data_sample]; --Nice to plot
SELECT DISTINCT COUNTRY FROM [dbo].[sales_data_sample]; --Nice to plot
SELECT DISTINCT DEALSIZE FROM [dbo].[sales_data_sample]; --Nice to plot
SELECT DISTINCT TERRITORY FROM [dbo].[sales_data_sample]; --Nice to plot


--ANALYSIS
--Let's start by grouping sales

SELECT 
	productline,
	SUM(SALES) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY productline
ORDER BY 2 DESC;


SELECT 
	year_id,
	SUM(SALES) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY year_id
ORDER BY 2 DESC;


SELECT 
	DEALSIZE,
	SUM(SALES) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY DEALSIZE
ORDER BY 2 DESC;


--What was the best month for sales in a specific year? How much was earned that month?

SELECT 
	month_id,
	SUM(Sales) AS revenue,
	COUNT(Ordernumber) AS frequency
FROM [dbo].[sales_data_sample]
WHERE year_id = 2003 --change year to see the rest
GROUP BY month_id
ORDER BY 2 DESC;


--November seems to be the best month, what product do they sell in November

SELECT 
	month_id,
	productline,
	SUM(sales) AS revenue,
	COUNT(Ordernumber) AS frequency
FROM [dbo].[sales_data_sample]
WHERE year_id = 2003 AND month_id = 11 --change year to see the rest
GROUP BY 
	month_id,
	productline
ORDER BY 3 DESC;


--Who is our best customer? Using RFM Analysis to answer the Question

DROP TABLE IF EXISTS #rfm
;with rfm as
(
	SELECT 
		customername,
		SUM(sales) MonetaryValue,
		AVG(sales) AS AvgMonetaryValue,
		COUNT(ordernumber) AS Frequency,
		MAX(orderdate) AS last_order_date,
		(SELECT MAX(orderdate) FROM [dbo].[sales_data_sample]) AS max_order_date,
		DATEDIFF(DD, MAX(orderdate), (SELECT MAX(orderdate) FROM [dbo].[sales_data_sample])) AS Recency
	FROM [dbo].[sales_data_sample]
	GROUP BY customername
),
rfm_calc AS
(
SELECT
	r.*,
	NTILE(4) OVER (order by recency DESC) AS rfm_recency,
	NTILE(4) OVER (order by frequency) AS rfm_frequency,
	NTILE(4) OVER (order by monetaryvalue) AS rfm_monetary
FROM rfm r
)
SELECT
	c.*,
	rfm_recency+rfm_frequency+rfm_monetary AS rfm_cell,
	cast(rfm_recency AS varchar)+cast(rfm_frequency AS varchar)+cast(rfm_monetary AS varchar) AS rfm_cell_string
INTO #rfm
FROM rfm_calc c

SELECT customername, rfm_recency, rfm_frequency, rfm_monetary,
	CASE
		WHEN rfm_cell_string IN(111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers' --lost customers
		WHEN rfm_cell_string IN(133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping away, cannot lose' --big spenders who haven't purchased lately
		WHEN rfm_cell_string IN(311, 411, 331) THEN 'new customers'
		WHEN rfm_cell_string IN(222, 223, 233, 322) THEN 'potential churners'
		WHEN rfm_cell_string IN(323, 333, 321, 422, 332, 432) THEN 'active' --customers who by often and recently but at low price points
		WHEN rfm_cell_string IN(433, 434, 444, 443) THEN 'loyal'
	END rfm_segment
FROM #rfm
