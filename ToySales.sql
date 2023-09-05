--which product categories drive the biggest profits?

select 
	p.product_category -- we want to see how each category performs
,	sum((p.product_price - p.product_cost)*sal.units) as product_profit --calculating the profit
from
	toy_products p
join
	toy_sales sal --joining sales table for the profit calculation
on 
	p.product_id = sal.product_id
group by
	p.product_category --grouping the profits by each product category
order by
	product_profit desc --sorting the categories by the highest profit(top) to the lowest profit(bottom)

--results: toys and electronics are the categories that bring the most profits


--is this the same across store locations?

select
	sto.store_location --to see how each location performs
,	p.product_category --to later group by 
,	sum((p.product_price - p.product_cost)*sal.units) as product_profit --calculating the profit
from
	toy_products p
join
	toy_sales sal --joining sales table for profit calculation
on 
	p.product_id = sal.product_id
join
	toy_stores sto --joining stores table for the locations
on 
	sal.store_id = sto.store_id
group by
	sto.store_location --grouping the profits by each location as well as category
,	p.product_category
order by
	sto.store_location --sorting the categories by the location as well as highest profit(top) to lowest profit(bottom)
,	product_profit desc

-- results: toys and electronics are the categories that bring the most profits across all store locations 


--which store location makes the most profits?

select
	sto.store_location  --to see how each location performs
,	sum((p.product_price - p.product_cost)*sal.units) as product_profit --calculating the profit
from
	toy_products p
join
	toy_sales sal --joining sales table for profit calculation
on 
	p.product_id = sal.product_id
join
	toy_stores sto --joining stores table for the locations
on 
	sal.store_id = sto.store_id
group by
	sto.store_location --grouping the profits by each location
order by
	product_profit desc --sorting the locations by highest profit(top) to lowest profit(bottom)

--results: downtown locations makes by far the most profits


--are there any seasonal trends or patterns in the sales data?
--i need to add an extra column to the sales table that represents the quarters of the year

alter table toy_sales
add Quarter nvarchar(50) --creating a new column in the toy_sales table that is named 'Quarter'

update toy_sales
set quarter = 'Q1' --marking every month in the first quarter with 'Q1' 
where date between '2017-01-01' and '2017-03-31' or date between '2018-01-01' and '2018-03-31'

update toy_sales
set quarter = 'Q2' --marking every month in the second quarter with 'Q2'
where date between '2017-04-01' and '2017-06-30' or date between '2018-04-01' and '2018-06-30'

update toy_sales
set quarter = 'Q3' --marking every month in the third quarter with 'Q3'
where date between '2017-07-01' and '2017-09-30' or date between '2018-07-01' and '2018-09-30'

update toy_sales
set quarter = 'Q4' --marking every month in the fourth quarter with 'Q4'
where date between '2017-10-01' and '2017-12-31' or date between '2018-10-01' and '2018-12-31'

--im also adding a 'year' column to better be able to compare the quarters in each year

alter table toy_sales
add Year nvarchar(50) --creating the 'Year' column

update toy_sales
set year = '2017' --marking every year in 2017 with '2017'
where date like '%2017%'

update toy_sales
set year = '2018' --marking every year in 2018 with '2018'
where date like '%2018%'


--back to the question if there are any seasonal trends
--creating multiple CTE's to see the revenue of each quarter side by side
--calculating the revenue for each quarter

;with q12017 as --CTE for Q1 in 2017
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2017_q1
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q1' and year = '2017'
),
q22017 as --CTE for Q2 in 2017
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2017_q2
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q2' and year = '2017'
),
q32017 as --CTE for Q3 in 2017
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2017_q3
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q3' and year = '2017'
),
q42017 as --CTE for Q4 in 2017
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2017_q4
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q4' and year = '2017'
),
q12018 as --CTE for Q1 in 2018
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2018_q1
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q1' and year = '2018'
),
q22018 as --CTE for Q2 in 2018
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2018_q2
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q2' and year = '2018'
),
q32018 as --CTE for Q3 in 2018
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2018_q3
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q3' and year = '2018'
),
q42018 as --CTE for Q4 in 2018
(
	select
		round(sum(p.product_price*sal.units),2) as rev_2018_q4
	from 
		toy_products p
	join 
		toy_sales sal
	on
		sal.product_id = p.product_id
	where 
		quarter = 'Q4' and year = '2018'
)
select --taking all the information from the CTE's and putting them in one line to be able to compare the revenues
	*
from 
	q12017
,	q22017
,	q32017
,	q42017
,	q12018
,	q22018
,	q32018
,	q42018


--results:	our revenue increases in q2 compared to q1,
--			after that there is a slight drop in q3 and in q4 we have a revenue increase again
--			it's the same for 2017 and 2018 but there is no data for q4 in 2018 yet 
--			although we should see a rise in revenue again compared to q3 2018

--			comparing the years we can see that 2018 has a big increase in revenue overall


--Are sales being lost with out-of-stock products at certain locations?

;with out_of_stock as --creating a CTE so i can rank the urgency to restock the items and run the query a couple times for each kind of location
(
	select
		sto.store_location --we want to see if we are losing out on sales in certain locations
	,	p.product_id --to see which products we need to restock asap
	,	sum(sal.units) as sales_quantity --summing up the sales of the products which are out of stock at each location
	,	rank() over(order by sum(sal.units)desc) as rnk --ranking the sum of the sales at each location to see which product where the urgency for restocking is the greatest
	from
		toy_stores sto		--joining all the tables that contain the data that i need for my CTE
	join			
		toy_sales sal
	on
		sto.store_id = sal.store_id	
	join
		toy_products p
	on
		sal.product_id = p.product_id
	join 
		toy_inventory inv
	on
		inv.product_id = sal.product_id
	where
		inv.stock_on_hand = 0 --filtering, so we only get products in the result that are out of stock
	group by
		sto.store_location
	,	p.product_id
)
select
	* --selecting all the information from the CTE 
from 
	out_of_stock
where 
	store_location = 'Downtown' --filtering the information from the CTE by the different store locations

--results:	we are losing out on massive sales in downtown locations with product 1, 15, 9, 21, 2, 3, 11 out of stock (in this order)
--			in commercial locations we should see that product 15, 1, 9, 21, 2 get restocked asap
--			in residential locations product 1, 15 and 21 should be restocked soon
--			and in airport locations it is not as urgent as in the other locations, but product 15, 1 and 9 should also be restocked asap


--How much money is tied up in inventory at the toy stores? And how long will it last?

;with inventoryvalue as --creating CTE for inventory value 
(
	select
		p.product_id
	,	sum(p.product_price * inv.stock_on_hand) as inventory_value --calculating the revenue per product that is stored in the inventory
	from
		toy_inventory inv
	join
		toy_products p
	on
		inv.product_id = p.product_id
	group by
		p.product_id
),
dailysales as --creating CTE for dailysales
(
	select
		sal.product_id
	,	sum(p.product_price*sal.units)/ 30 as daily_sales --calculating the revenue per product per day that is being sold
	from
		toy_sales sal
	join
		toy_products p
	on
		sal.product_id = p.product_id
	where
		date between '2018-09-01' and '2018-09-30' --filtering the last month in the database to calculate the daily sales 
	group by
		sal.product_id
)
select
	inv.product_id 
,	round(sum(inv.inventory_value/ dsal.daily_sales),2) as estimated_days_to_last --calculating the days our stored products will last based on the last month in the database records
from
	inventoryvalue inv
join
	dailysales dsal
on
	inv.product_id = dsal.product_id
group by
	inv.product_id
order by
	estimated_days_to_last --sorting the results ascending so the item that is closest to being out of stock appears at the top

--results:	product 28 is the closest to being unavailable, it's being sold completely in the next 4 days approximately
--			products 3, 9 and 15 will last another 7-8 days and every other product 10+ days
