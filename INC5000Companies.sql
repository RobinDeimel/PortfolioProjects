--What's the average revenue among companies on the list?

SELECT
	AVG(revenue) AS total_avg --Selecting the average revenue from all companies
FROM 
	[dbo].[INC5000Companies2019]


--Broken down by industry?

SELECT
	industry --to see how each one performs in terms of average revenue
,	AVG(revenue) AS industry_avg --selecting the average revenue from all companies
FROM 
	[dbo].[INC5000Companies2019]
GROUP BY
	industry --grouping the average revenue by each industry
ORDER BY
	industry_avg DESC --sorting the industries by highest average revenue(top) to smallest average revenue(bottom)


--Which industries are most and least represented in the list?

SELECT
	industry --to see how many companies per industry are represented in the list
,	COUNT(company) AS cnt_comp --counting all companies
FROM
	[dbo].[INC5000Companies2019]
GROUP BY
	industry --grouping the counted companies by each industry 
ORDER BY 
	cnt_comp DESC --sorting the industries by the most companies represented(top) to the least represented(bottom)


--Trying to see if there are any interesting geographic trends

SELECT
	state --to see how many companies are there in each state
,	COUNT(company) AS cnt_comp --counting all companies
FROM 
	[dbo].[INC5000Companies2019]
GROUP BY
	state --grouping the counted companies by each state
ORDER BY
	cnt_comp DESC --sorting the state by the most companies(top) to the least companies(bottom)


--Which industries saw the largest average growth rate?


SELECT
	industry --to see how much the growth was for each industry
,	AVG([growth_%]) AS [avg_growth_%] --getting the average growth of all companies
FROM 
	[dbo].[INC5000Companies2019]
GROUP BY
	industry --grouping the average growth by each industry
ORDER BY 
	[avg_growth_%] DESC --sorting the industries by biggest average growth(top) to smallest average growth(bottom)


--Which companies had the largest increase in staff/new hires?

SELECT
	company --to see how much each companies' staff increased
,	workers - previous_workers AS no_staff --subtracting the number of workers by the number of the previous workers 
FROM 
	[dbo].[INC5000Companies2019]
ORDER BY
	no_staff DESC --sorting the companies by most new hires(top) to least new hires(bottom)


--Did any companies increase revenue while reducing staff?

;WITH staff_rev AS --creating a CTE with the companies, their growth and the number of their staff in/decrease
(
	SELECT
		company
	,	[growth_%]
	,	workers - previous_workers AS no_staff
	FROM
		[dbo].[INC5000Companies2019]
)
SELECT 
	COUNT(company) AS no_comp --counting all the companies 
FROM 
	staff_rev
WHERE 
	no_staff < 0 AND [growth_%] > 0 --filtering the outcome so that only companies with a staff DEcrease and a growth INcrease are getting counted
