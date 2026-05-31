USE DATABASE nyc_taxi_db;
USE SCHEMA STAGING;

CREATE OR REPLACE TABLE STAGING.stg_yellow_taxi_trips AS
SELECT
    "VendorID",
    TO_TIMESTAMP("tpep_pickup_datetime"/1000000) AS pickup_datetime,
    TO_TIMESTAMP("tpep_dropoff_datetime"/1000000) AS dropoff_datetime,
    "passenger_count","trip_distance","fare_amount","tip_amount","payment_type","PULocationID","DOLocationID",
    DATE(
        TO_TIMESTAMP("tpep_pickup_datetime"/1000000)
    ) AS pickup_date,
    EXTRACT(HOUR FROM
        TO_TIMESTAMP("tpep_pickup_datetime"/1000000)
    ) AS pickup_hour,
    DAYNAME(
        TO_TIMESTAMP("tpep_pickup_datetime"/1000000)
    ) AS weekday_name,
    MONTH(
        TO_TIMESTAMP("tpep_pickup_datetime"/1000000)
    ) AS trip_month,
    DATEDIFF(
        MINUTE,
        TO_TIMESTAMP("tpep_pickup_datetime" / 1000000),
        TO_TIMESTAMP("tpep_dropoff_datetime" / 1000000)
    ) AS trip_duration_minutes
FROM RAW.YELLOW_TAXI_TRIPS
WHERE
    "trip_distance" > 0 AND "fare_amount" > 0 AND
    "total_amount" > 0 AND "tpep_dropoff_datetime" > "tpep_pickup_datetime"
    AND year(
        TO_TIMESTAMP("tpep_pickup_datetime" / 1000000)
    ) = 2026

    AND month(
        TO_TIMESTAMP("tpep_pickup_datetime" / 1000000)
    ) BETWEEN 1 AND 4;

    SELECT * FROM STAGING.stg_yellow_taxi_trips
    LIMIT 10;

    ALTER WAREHOUSE taxi_data SUSPEND;

    SELECT
MIN(pickup_date),
MAX(pickup_date)
FROM STAGING.STG_YELLOW_TAXI_TRIPS;