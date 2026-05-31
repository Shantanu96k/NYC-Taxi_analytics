use database NYC_TAXI_DB;
use schema analytics;

-- KPI querry
-- How many taxi trips were completed during the period covered by our dataset?

SELECT COUNT(*) as total_trip FROM analytics.fact_trip;
-- Output: 14163328


-- What is the total revenue generated from all taxi trips?
SELECT sum(total_amount) as total_revenue
FROM analytics.fact_trip;
-- Output: 342260263.41


-- What is the average fare charged per trip?
SELECT round(avg(total_amount),2) as average_fare
from analytics.fact_trip;
-- Output: 24.17

--What is the average distance traveled per trip?
SELECT round(avg("trip_distance"),2) as avg_distance
FROM analytics.fact_trip;
--Output: 6.2

-- What is the average trip duration in minutes?
SELECT round(avg(trip_duration_minutes),2) as avg_duration
FROM analytics.fact_trip;
--Output: 17.89

-- Analysis Querry
--Which month generated the highest revenue?
SELECT d.month_name,sum(f.total_amount) as total_amount
FROM fact_trip f LEFT JOIN dim_date d 
ON f.date_key = d.date_key
GROUP BY d.month_name
ORDER BY sum(f.total_amount) DESC;
--Output: Mar	91344638.12

-- Which day of the week has the highest number of trips?
SELECT d.day_of_week,d.weekday_name,count(*) as total_trips
FROM fact_trip f LEFT JOIN dim_date d 
ON f.date_key = d.date_key
GROUP BY d.day_of_week, d.weekday_name
ORDER BY total_trips DESC;
-- Output: 4	Thu	2327305

--Which month generated the Lowest revenue?
SELECT d.month_name,sum(f.total_amount) as total_amount
FROM fact_trip f LEFT JOIN dim_date d 
ON f.date_key = d.date_key
GROUP BY d.month_name
ORDER BY sum(f.total_amount);
-- Output: May	12.19.

-- Which weekday generates the highest revenue?
SELECT d.weekday_name, d.day_of_week, sum(f.total_amount) as total_revenue
FROM fact_trip f LEFT JOIN dim_date d
ON f.date_key = d.date_key
GROUP BY d.weekday_name, d.day_of_week
ORDER BY sum(f.total_amount) DESC;
-- Output: Thu	4	57618031.29

--Which weekday has the most trips?
SELECT d.weekday_name,d.day_of_week, count(*) as most_trips
FROM fact_trip f LEFT JOIN dim_date d
ON f.date_key = d.date_key
GROUP BY d.weekday_name,d.day_of_week
ORDER BY count(*) DESC;
--Output: Thu	4	2327305

--Top 10 Pickup Locations by Number of Trips
SELECT l.location_id, count(*) as total_pickup
FROM fact_trip f LEFT JOIN dim_location l
ON f."PULocationID" = l.location_id
GROUP BY l.location_id 
ORDER BY count(*) DESC
LIMIT 10;
/*Ouput:
LOCATION_ID	TOTAL_PICKUP
237	634345
161	584060
236	582360
132	548347
186	430046
162	429050
142	410085
230	406759
79	380168
239	367618*/


--Top 10 Pickup Locations by Revenue
SELECT l.location_id, sum(f.total_amount) as total_revenue
FROM fact_trip f LEFT JOIN dim_location l
ON f."PULocationID" = l.location_id
GROUP BY l.location_id
ORDER BY sum(f.total_amount) DESC
LIMIT 10;
/* Output : 
LOCATION_ID	TOTAL_REVENUE
132	38913044.36
138	18654833.44
161	12368214.37
237	10519027.48
236	10131263.69
230	9606701.26
186	8890528.87
162	8598849.45
79	7667344.53
68	7637148.46 */

--Which Vendor Generates More Revenue?
SELECT v."VendorID", sum(f.total_amount) as total_revenue
FROM fact_trip f LEFT JOIN dim_vendor v
ON f."VendorID" = v."VendorID"
GROUP BY v."VendorID"
ORDER BY sum(f.total_amount) DESC
LIMIT 1;
-- Output: 2	276319706.75

--Average Revenue Per Trip By Month
SELECT d.month_name, round(avg(f.total_amount),2) as avg_revenue
FROM fact_trip f LEFT JOIN dim_date d
ON f.date_key = d.date_key
group by d.month_name
order by round(avg(f.total_amount)) desc;
--Output: Dec	62.97

--On which weekday do passengers spend the most time in taxis?
SELECT d.weekday_name, round(avg(f.trip_duration_minutes),2) as average_duration 
FROM fact_trip f LEFT JOIN dim_date d 
ON f.date_key = d.date_key
group by d.weekday_name
order by average_duration desc;
--Output: Thu	18.89
-- Wed	18.85
-- Tue	18.62

-- Which day of the week earns the most money?
SELECT d.day_of_week, sum(f.total_amount) as total_amount_week
FROM fact_trip f LEFT JOIN dim_date d 
ON f.date_key = d.date_key
group by d.day_of_week
order by total_amount_week desc;
--Output: 4	57618031.29

-- Rank vendors from highest revenue to lowest revenue.
SELECT "VendorID", sum(total_amount) as revenue,
rank() over (order by sum(total_amount) desc) as rank_vendor
FROM fact_trip
group by "VendorID";
/* output: 
VendorID	REVENUE	RANK_VENDOR
2	276319706.75	  1
1	65861867.66	      2
6	78689 	          3 */


--Show Top 5 pickup locations by revenue.

SELECT * FROM (SELECT l.location_id, sum(total_amount) as revenue,
ROW_NUMBER() OVER (ORDER BY revenue desc) as row_num
FROM fact_trip f LEFT JOIN dim_location l 
ON f."PULocationID" = l.location_id
group by l.location_id)
where row_num <=5;
/* Output:
LOCATION_ID	REVENUE	ROW_NUM
132         38913044.36	1
138	        18654833.44	2
161	        12368214.37	3
237	        10519027.48	4
236	        10131263.69	5  */

-- Show cumulative revenue over time.
with monthly_revenue as (SELECT d.month_name,d.month,
SUM(f.total_amount) as revenue
FROM fact_trip f LEFT JOIN dim_date d
ON f.date_key = d.date_key
GROUP BY d.month_name,d.month )
SELECT month_name,month, 
sum(revenue) over (order by month) as running_revenue
from monthly_revenue
order by month;

-- How much revenue grew or declined compared to the previous month?
WITH monthly_revenue AS(
SELECT d.month, d.month_name,
sum(f.total_amount) as revenue
FROM fact_trip f JOIN dim_date d
ON f.date_key = d.date_key
group by d.month,d.month_name
)
SELECT month,month_name, revenue,
LAG(revenue) OVER (ORDER BY month) as previous_month_revenue,
revenue - LAG(revenue) OVER (ORDER BY month) as growth
from monthly_revenue;
/* Output:
MONTH	MONTH_NAME	REVENUE	PREVIOUS_MONTH_REVENUE	GROWTH
1	      Jan	    83570045.1		NULL            NULL
2	      Feb	    78712953.77	83570045.1	     -4857091.33
3	      Mar	    91344638.12	78712953.77	    12631684.35
4	      Apr	    88632144.83	91344638.12     -2712493.29000001 */

