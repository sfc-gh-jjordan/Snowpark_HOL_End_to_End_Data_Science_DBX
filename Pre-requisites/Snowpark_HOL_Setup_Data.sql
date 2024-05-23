/**********Setup HOL Database with Data**********/
USE ROLE accountadmin;

-- create a development database for data science work
CREATE OR REPLACE DATABASE HOL;

-- use the PUBLIC schema
USE SCHEMA PUBLIC;

-- create csv file format
CREATE OR REPLACE FILE FORMAT csv_ff type = 'csv';

-- create an external stage pointing to S3
CREATE OR REPLACE STAGE S3TASTYBYTES
COMMENT = 'Quickstarts S3 Stage Connection'
url = 's3://sfquickstarts/frostbyte_tastybytes/'
file_format = csv_ff;

-- define shift sales table
CREATE OR REPLACE TABLE shift_sales(
	location_id NUMBER(19,0),
	city VARCHAR(16777216),
	date DATE,
	shift_sales FLOAT,
	shift VARCHAR(2),
	month NUMBER(2,0),
	day_of_week NUMBER(2,0),
	city_population NUMBER(38,0)
);

-- create and use a compute warehouse
CREATE OR REPLACE WAREHOUSE hol_setup_wh warehouse_size = 'xsmall' AUTO_SUSPEND = 60;
USE WAREHOUSE hol_setup_wh;

-- ingest from S3 into the shift sales table
COPY INTO shift_sales
FROM @S3TASTYBYTES/analytics/shift_sales/;

-- join in SafeGraph data
CREATE OR REPLACE TABLE shift_sales
  AS
SELECT
    a.location_id,
    a.city,
    a.date,
    a.shift_sales,
    a.shift,
    a.month,
    a.day_of_week,
    a.city_population,
    b.latitude,
    b.longitude
FROM shift_sales a
JOIN frostbyte_safegraph.public.frostbyte_tb_safegraph_s b
ON a.location_id = b.location_id;

-- promote the harmonized table to the analytics layer for data science development
CREATE OR REPLACE VIEW SHIFT_SALES_V
  AS
SELECT * FROM SHIFT_SALES;

SELECT COUNT(*) as count_rows FROM SHIFT_SALES; --1,938,202

-- view shift sales data
SELECT * FROM SHIFT_SALES_V;

/**********Setup Cortex ML Forecasting Data**********/

-- use the PUBLIC schema
USE SCHEMA PUBLIC;

-- create csv file format
CREATE OR REPLACE FILE FORMAT csv_ff2
	TYPE=CSV
    SKIP_HEADER=1
    FIELD_DELIMITER=','
    TRIM_SPACE=TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY='"'
    REPLACE_INVALID_CHARACTERS=TRUE
    DATE_FORMAT=AUTO
    TIME_FORMAT=AUTO
    TIMESTAMP_FORMAT=AUTO;

-- Create an external stage pointing to s3, to load sales data:
CREATE OR REPLACE STAGE S3TASTYBYTES_Cortex
COMMENT = 'Quickstart S3 Stage Connection'
url = 's3://sfquickstarts/frostbyte_tastybytes/mlpf_quickstart/'
file_format = csv_ff2;

-- Define Tasty Byte Sales Table
CREATE OR REPLACE table sales(
  	DATE TIMESTAMP_NTZ,
	PRIMARY_CITY VARCHAR,
	MENU_ITEM_NAME VARCHAR,
	TOTAL_SOLD NUMBER(38,0)
);

-- Ingest data from s3 into our table
COPY INTO sales
FROM @S3TASTYBYTES_Cortex
FILES = ('mlpf_quickstart_vancouver_daily_sales.csv')
FILE_FORMAT = csv_ff2
ON_ERROR=CONTINUE ;

-- Create Table containing the latest years worth of sales data:
CREATE OR REPLACE view sales_forecast_input AS (
    SELECT
        to_timestamp_ntz(date) as timestamp,
        primary_city,
        menu_item_name,
        total_sold
    FROM
        sales
    WHERE
        date > (SELECT max(date) - interval '1 year' FROM sales)
    GROUP BY
        all
);

select * from sales_forecast_input limit 100;

