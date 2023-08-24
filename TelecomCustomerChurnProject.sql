--How many customers joined the company during the last quarter?

SELECT 
	COUNT(*)
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Joined'


--How many customers left?

SELECT 
	COUNT(*)
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'


--How are the customers that churned, joined, and stayed divided among the offers/contracts?
--Looking at the Offer

WITH Joined AS
(
	SELECT 
		Offer
	,	COUNT(*) AS joinedcount
	FROM [dbo].[telecom_customer_churn]
	WHERE [Customer Status] = 'Joined'
	GROUP BY
		Offer
),
Churned AS
(
	SELECT
		Offer
	,	COUNT(*) AS churnedcount
	FROM [dbo].[telecom_customer_churn]
	WHERE [Customer Status] = 'Churned'
	GROUP BY
		Offer
),
Stayed AS
(
	SELECT
		Offer
	,	COUNT(*) AS stayedcount
	FROM [dbo].[telecom_customer_churn]
	WHERE [Customer Status] = 'Stayed'
	GROUP BY
		Offer
)
SELECT DISTINCT
	tcc.offer
,	j.joinedcount
,	c.churnedcount
,	s.stayedcount
FROM [dbo].[telecom_customer_churn] tcc
LEFT JOIN Joined j
	ON tcc.Offer = j.offer
JOIN Churned c
	ON tcc.Offer = c.offer
JOIN Stayed s
	ON tcc.Offer = s.Offer
ORDER BY 
	tcc.Offer


--Looking at the Contract

WITH Joined AS
(
	SELECT 
		Contract
	,	COUNT(*) AS joinedcount
	FROM [dbo].[telecom_customer_churn]
	WHERE [Customer Status] = 'Joined'
	GROUP BY
		Contract
),
Churned AS
(
	SELECT
		Contract
	,	COUNT(*) AS churnedcount
	FROM [dbo].[telecom_customer_churn]
	WHERE [Customer Status] = 'Churned'
	GROUP BY
		Contract
),
Stayed AS
(
	SELECT
		Contract
	,	COUNT(*) AS stayedcount
	FROM [dbo].[telecom_customer_churn]
	WHERE [Customer Status] = 'Stayed'
	GROUP BY
		Contract
)
SELECT DISTINCT
	tcc.contract
,	j.joinedcount
,	c.churnedcount
,	s.stayedcount
FROM [dbo].[telecom_customer_churn] tcc
JOIN Joined j
	ON tcc.contract = j.contract
JOIN Churned c
	ON tcc.contract = c.contract
JOIN Stayed s
	ON tcc.contract = s.contract
ORDER BY 
	tcc.contract


--What seem to be the key drivers of customer churn?

SELECT 
	[Churn Reason]
,	COUNT(*) AS count_churned
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
GROUP BY 
	[Churn Reason]
ORDER BY 
	count_churned DESC


--Is the company losing high value customers? If so, how can they retain them?
--Looking at Churn Category
--Treating all Customers above the average revenue as high value customers

SELECT
	[Churn Category]
,	COUNT(*) AS countchurned
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned' 
AND [Total Revenue] > (SELECT 
			AVG([Total Revenue]) 
			FROM [dbo].[telecom_customer_churn])
GROUP BY 
	[Churn Category]
ORDER BY	
	countchurned DESC

--Looking at Churn Reason
--Treating all Customers above the average revenue as high value customers

SELECT
	[Churn Reason]
,	COUNT(*) AS countchurned
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
AND [Total Revenue] > (SELECT 
			AVG([Total Revenue]) 
			FROM [dbo].[telecom_customer_churn])
GROUP BY 
	[Churn Reason]
ORDER BY	
	countchurned DESC
