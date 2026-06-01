# NYC Taxi Analytics — Cloud Data Warehouse & Dashboard

![AWS S3](https://img.shields.io/badge/AWS%20S3-Storage-FF9900?style=flat&logo=amazonaws&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Data%20Warehouse-29B5E8?style=flat&logo=snowflake&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-Analytics-4479A1?style=flat&logo=postgresql&logoColor=white)

An end-to-end cloud analytics pipeline that ingests, transforms, models, and visualizes **14 million+ NYC Yellow Taxi trip records** using AWS S3, Snowflake, SQL, and Power BI.


---

##  Overview

This project demonstrates a production-style modern data warehouse built on the cloud. It follows a **RAW → STAGING → ANALYTICS** layered architecture to deliver clean, reliable data to business intelligence dashboards.

| Metric | Value |
|---|---|
| Total Records Processed | 14,163,328+ |
| Data Format | Parquet |
| Time Period | Jan 2023 – Apr 2023 |
| Cloud Platform | AWS S3 + Snowflake |
| Visualization | Power BI |

---

## Architecture

```
NYC Taxi Parquet Files
        │
        ▼
     AWS S3
        │
        ▼
Snowflake External Stage
        │
        ▼
     RAW Layer          
        │
        ▼
  STAGING Layer         
        │
        ▼
FACT & DIMENSION Tables 
        │
        ▼
  Power BI Dashboard   
```

---

## Technology Stack

| Category | Technology |
|---|---|
| Cloud Storage | AWS S3 |
| Data Warehouse | Snowflake |
| Querying & Transformation | SQL / Snowflake SQL |
| Data Modeling | Star Schema (Fact + Dimension Tables) |
| Visualization | Power BI |
| Data Format | Parquet |

---

## Dataset

**Source:** [NYC Open Data – Yellow Taxi Trip Records](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

**Files Used:**
- `yellow_tripdata_2026-01.parquet`
- `yellow_tripdata_2026-02.parquet`
- `yellow_tripdata_2026-03.parquet`
- `yellow_tripdata_2026-04.parquet`

**Total Records:** 14,163,328+

---

## Data Pipeline

### Step 1 — Data Ingestion
- Downloaded NYC Taxi Parquet files from NYC Open Data
- Uploaded files to **AWS S3** bucket
- Created Snowflake **External Stage** pointing to S3

### Step 2 — RAW Layer
- Loaded source data into Snowflake `RAW` schema
- Preserved original structure without any transformations

### Step 3 — STAGING Layer
Applied the following transformations:
- Timestamp conversion and parsing
- Data cleansing and null handling
- Invalid trip filtering (zero distance, negative fares, etc.)
- Trip duration calculation
- Date part extraction (year, month, day, hour, weekday)
- Business attribute generation (time of day, trip category)

### Step 4 — Analytics Layer
- Built **Fact** and **Dimension** tables using Star Schema
- Created pre-aggregated analytical views for Power BI

---

## Data Modeling

### Star Schema Design

```
              DIM_DATE
                 │
DIM_VENDOR ── FACT_TRIP ── DIM_LOCATION
```

#### FACT_TRIP
| Column | Description |
|---|---|
| trip_id | Surrogate key |
| date_key | FK → DIM_DATE |
| vendor_key | FK → DIM_VENDOR |
| pickup_location_key | FK → DIM_LOCATION |
| dropoff_location_key | FK → DIM_LOCATION |
| fare_amount | Base fare |
| tip_amount | Tip given |
| total_revenue | Total trip revenue |
| trip_distance | Distance in miles |
| trip_duration_mins | Duration in minutes |

#### DIM_DATE
Contains: Date, Month, Month Name, Day of Week, Year, Quarter

#### DIM_VENDOR
Contains: Vendor ID, Vendor Name

#### DIM_LOCATION
Contains: Location ID, Borough, Zone, Service Zone

---

## Business KPIs

### Executive KPIs
- Total Revenue
- Total Trips
- Average Fare per Trip
- Average Trip Distance
- Average Trip Duration

### Operational KPIs
- Revenue by Month
- Trips by Month
- Trips by Weekday
- Revenue by Vendor
- Peak Pickup Hours

### Location KPIs
- Top Pickup Locations by Revenue
- Top Pickup Locations by Trip Volume

---

## Advanced SQL Analysis

### Aggregation & Grouping
```sql
SELECT vendor_id, SUM(total_revenue), AVG(trip_distance), COUNT(*) AS total_trips
FROM FACT_TRIP
GROUP BY vendor_id;
```

### Window Functions Used
- `ROW_NUMBER()` — Ranking trips per vendor
- `RANK()` / `DENSE_RANK()` — Vendor performance ranking
- `LAG()` — Month-over-Month revenue comparison
- Running Totals — Cumulative revenue by date

### Month-over-Month Revenue Growth (CTE + LAG)
```sql
WITH monthly_revenue AS (
    SELECT month, SUM(total_revenue) AS revenue
    FROM FACT_TRIP f JOIN DIM_DATE d ON f.date_key = d.date_key
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly_revenue;
```

---

## Power BI Dashboard

### Executive Dashboard
- Total Revenue, Total Trips, Average Fare (KPI Cards)
- Monthly Revenue Trend (Line Chart)
- Monthly Trip Volume Trend (Bar Chart)

### Operations Dashboard
- Revenue by Vendor (Donut Chart)
- Trips by Weekday (Column Chart)
- Peak Pickup Hour Heatmap

### Location Dashboard
- Top 10 Pickup Locations by Revenue (Bar Chart)
- Top 10 Pickup Locations by Trip Count (Bar Chart)

---

## Repository Structure

```
NYC-Taxi-Analytics/
│
├── sql/
│   ├── 01-create-wh.sql
│   ├── 02-create-db.sql
│   ├── 03-extract-raw-data.sql
│   ├── 05-transform-data.sql
│   ├── 06-star_schema_data.sql
│   └── 07-Insight.sql│
├── dashboard/
│   └── NYC_Taxi_Dashboard.pbix       
│
├── screenshots/
│   
└── README.md
```

---

## Key Learnings

- Designing a multi-layer data warehouse (RAW → STAGING → ANALYTICS)
- Setting up Snowflake External Stages with AWS S3
- Writing production-grade SQL with CTEs and Window Functions
- Building a Star Schema for OLAP reporting
- Creating business KPI dashboards in Power BI

---



## Author

**Shantanu Sawant**
Data Analyst 

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](https://www.linkedin.com/in/shantanu-sawant-96k/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat&logo=github)](https://github.com/Shantanu96k)

**Skills:** SQL · Snowflake · AWS S3 · Power BI · Python · Data Analytics
