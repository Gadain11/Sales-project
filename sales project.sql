
---Inspecting Data
select* from sales_data_sample

--CHecking unique values

select distinct status from dbo.sales_data_sample
select distinct YEAR_ID from dbo.sales_data_sample
select distinct PRODUCTLINE from dbo.sales_data_sample
select distinct COUNTRY from dbo.sales_data_sample
select distinct DEALSIZE from dbo.sales_data_sample
select distinct TERRITORY from dbo.sales_data_sample

select distinct MONTH_ID from dbo.sales_data_sample 
where YEAR_ID = 2004 

-- Analysis
---- grouping sales by productline
select PRODUCTLINE, sum(SALES) REVENUE
from dbo.sales_data_sample
group by PRODUCTLINE
order by 2 DESC

select year_id, sum(SALES) REVENUE
from dbo.sales_data_sample
group by year_id
order by 2 DESC

----What was the best month for sales in a specific year? How much was earned that month? 

select month_id ,sum(SALES) revenue , count(ORDERLINENUMBER) frequncey
from dbo.sales_data_sample
where YEAR_ID = 2003
group by month_id
order by 2 desc

-- best proudct in november 
select PRODUCTLINE ,sum(SALES) revenue, YEAR_ID
from dbo.sales_data_sample
where MONTH_ID = 11
group by PRODUCTLINE,YEAR_ID
order by 3,2 desc

-- who is our best customer ( rmf analysis)

DROP TABLE IF EXISTS #rfm ;
with rfm as 
(
	select CUSTOMERNAME,
	sum(SALES) monetaryvalue,
	avg(SALES) avgmonetaryvalue,
	count(ORDERLINENUMBER) frequancy,
	max(orderdate) last_order_date,
	(select max(ORDERDATE) from dbo.sales_data_sample) maxdate,
	DATEDIFF(DD,max(orderdate) ,(select max(ORDERDATE) from dbo.sales_data_sample)) recency
	from dbo.sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		NTILE(4) over ( order by recency desc) rfm_recency,
		NTILE(4) over ( order by frequancy) rfm_frequancy,
		NTILE(4) over ( order by monetaryvalue) rfm_monetaryvalue

	from rfm r
)
select 
	c.* , rfm_recency + rfm_frequancy + rfm_monetaryvalue as rfm_cell,
	cast(rfm_recency as varchar) + cast (rfm_frequancy as varchar)+ cast (rfm_monetaryvalue as varchar) rfm_cell_string 
into #rfm
from rfm_calc c

select CUSTOMERNAME,rfm_recency , rfm_frequancy , rfm_monetaryvalue,
case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm








