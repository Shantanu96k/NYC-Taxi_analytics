use database nyc_taxi_db;
use schema analytics;

CREATE OR REPLACE TABLE analytics.dim_date AS
SELECT DISTINCT
PICKUP_DATE AS date_key,
PICKUP_DATE AS full_date,
YEAR(PICKUP_DATE) as year,
QUARTER(PICKUP_DATE) as quarter,
MONTH(PICKUP_DATE) as month,
MONTHNAME(PICKUP_DATE) as month_name,
DAY(PICKUP_DATE) as day,
DAYOFWEEK(PICKUP_DATE) as day_of_week,
weekday_name
FROM STAGING.stg_yellow_taxi_trips;

SELECT * FROM staging.stg_yellow_taxi_trips
limit 10;
SELECT * FROM analytics.dim_date
limit 10;

CREATE OR REPLACE TABLE analytics.dim_vendor AS
SELECT DISTINCT
"VendorID"
FROM staging.stg_yellow_taxi_trips;

select * from analytics.dim_vendor;

CREATE OR REPLACE TABLE analytics.dim_location AS
SELECT DISTINCT
"PULocationID" AS location_id
FROM staging.stg_yellow_taxi_trips
UNION
SELECT DISTINCT
"DOLocationID" as droff_location_id
FROM staging.stg_yellow_taxi_trips;

select * from analytics.dim_location
limit 10;

CREATE OR REPLACE TABLE analytics.fact_trip AS
SELECT
pickup_date AS date_key,
"VendorID",
"PULocationID",
"DOLocationID",
"passenger_count",
"trip_distance",
"fare_amount",
"tip_amount",
COALESCE("fare_amount",0)+COALESCE("tip_amount",0) as total_amount,
trip_duration_minutes
FROM STAGING.STG_YELLOW_TAXI_TRIPS;

select * from analytics.fact_trip
limit 10
select * from analytics.dim_location
limit 10;
select * from analytics.dim_date
limit 10;
select * from analytics.dim_vendor
limit 10;