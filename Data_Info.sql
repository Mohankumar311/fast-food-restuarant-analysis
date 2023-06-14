--create database restaurantDB
use  restaurantDB

select * from pos

--Total Revenue
select sum([Total_Price]) from pos

--No of orders
Select count(distinct order_id) from pos

--top 5 customers by revenue
select top 5 Customer_ID, sum(Total_price) from pos
group by Customer_ID
order by sum(Total_price) desc


--Total no of orders by top 10 customers
select sum(No_of_orders) from (select top 10 Customer_ID, count(Total_price)[No_of_orders] from pos
group by Customer_ID
order by count(Total_price) desc) as t

-- Number of customers (Distinct)
select  count(distinct customer_id) from pos

--Number of customers ordered once
select count (customer_id) [No of customer ordered  1 time]from (select Customer_id, count(customer_id)[no_of_orders] from pos
group by Customer_ID
having count(customer_id)=1) as t1

--Number of customers ordered multiple times
select count(customer_id)[No of customer ordered more than 1 time] from (select customer_id, count(customer_id)[no_of_orders] from pos
group by customer_id
having count(customer_id)>1) as t1

--Which Month have maximum Revenue?
select month(Date_time), sum(Total_price) from pos
group by month(Date_time)
order by sum(Total_price) desc

--Growth Rate  (%) in revenue (from Mar’22 to Nov’22)
WITH mar22 AS (
  SELECT SUM(total_price) [mar22]
  FROM pos
  WHERE Date_Time BETWEEN '2022-03-01' AND '2022-03-31'
), nov22 AS (
  SELECT SUM(total_price) [nov22]
  FROM pos
  WHERE Date_Time BETWEEN '2022-11-01' AND '2022-11-30'
)
SELECT ROUND(((mar22 - nov22) / nov22) * 100, 2) AS growth_rate
FROM nov22, mar22;

--Growth Rate  (%) in Orders (from Mar’22 to Nov’22)
with mar22 as(
select count(order_id)[mar22] from pos
where Date_Time between '2022-03-01' and '2022-03-31'),
nov22 as(
select count(order_id)[nov22] from pos
where Date_Time between '2022-11-01' and '2022-11-30')
select ((CAST(mar22 AS decimal)- CAST(nov22 AS decimal))/CAST(mar22 AS decimal)) * 100 as growth_rate from nov22,mar22


--What is the percentage of upi payments

WITH upii AS (
  SELECT COUNT(DISTINCT order_id) AS upi
  FROM pos
  WHERE Payment = 'upi'
), totall AS (
  SELECT COUNT(DISTINCT order_id) AS total
  FROM pos
)
SELECT ROUND((CAST(upi AS decimal) / total *100), 2) AS percentage
FROM upii, totall;

-- Which store have maximum customers?
select store_id,count(Order_ID) from pos
group by Store_id
order by count(Order_ID) desc

-- What is the percentage of biriyani sales in store a?
with biriyanii as(
select count(order_id)[biriyani] from pos
where Category='biriyani'),
totall as(
select count(order_id) [total] from pos)
select round(cast([biriyani] as float)/cast([total] as float)*100,2)[percentage] from biriyanii, totall

--Which month having maximum order value from biriyani belongs to store A? 
select top 1 month(date_time)[month],sum(total_price)[revenue]from pos
where store_id='a'
group by month(date_time)
order by sum(total_price) desc

-- total revenue by month based for each store
WITH cte AS (
  SELECT 
    month(Date_Time) AS [Month], 
    store_id, 
    sum(total_price) AS total_price
  FROM pos
  GROUP BY month(Date_Time), store_id
)
SELECT *
FROM cte
PIVOT (
  SUM(total_price)
  FOR store_id IN ([a], [b], [c])
) AS PivotTable;



--total revenue for each category by each store
with cte1 as(
select category,store_id, sum(cast(total_price as float))[totalprice]  from pos
group by  store_id, category)
select * from cte1
pivot(
sum(totalprice) for store_id in ([a],[b],[c]))as pivottable

----Q3. Month-on-month growth in OrderCount and Revenue (from feb'22 to July’22)
with cte2 as (select month(date_time)[month],year(date_time)[year],sum(total_price)[price],count(total_price)[orders] from pos
group by month(date_time), year(date_time) )
select *,(price-lag(price)over (order by [year],[month]))/price *100 ,(cast(orders as float)-lag(cast(orders as float))over (order by [year],[month]))/cast(orders as float) *100  from cte2
order by [year], [month]





