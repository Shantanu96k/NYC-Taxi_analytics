CREATE warehouse taxi_data
with
warehouse_size = 'small'
auto_suspend = 60
auto_resume = true;

ALTER WAREHOUSE taxi_data SUSPEND;
