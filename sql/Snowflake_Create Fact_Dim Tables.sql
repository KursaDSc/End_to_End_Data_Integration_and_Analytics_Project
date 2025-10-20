-- =========================================================
-- 1. USE warehouse, database, and DWH schema (GOLD layer)
-- =========================================================
USE WAREHOUSE SAKILA_WH;
USE DATABASE SAKILA_PROD;
-- Working in the DWH schema for the final star schema tables
USE SCHEMA DWH;

-- NOTE: This code ensures data preservation by using LEFT JOINs 
-- and the 'Unknown Member' (-1) pattern for missing dimension keys.

-- =========================================================
-- 2. DIM_CUSTOMER (No change to CREATE/INSERT - Retains IDENTITY SK)
-- =========================================================
CREATE OR REPLACE TABLE DIM_CUSTOMER (
    CUSTOMER_KEY NUMBER(38,0) IDENTITY(1,1) PRIMARY KEY,
    CUSTOMER_ID NUMBER(38,0),
    FULL_NAME VARCHAR(101),
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    EMAIL VARCHAR(50),
    STORE_ID NUMBER(38,0),
    ADDRESS_ID NUMBER(38,0),
    IS_ACTIVE BOOLEAN,
    DW_CREATE_DATE TIMESTAMP_NTZ(9)
);

INSERT INTO DIM_CUSTOMER (CUSTOMER_ID, FULL_NAME, FIRST_NAME, LAST_NAME, EMAIL, STORE_ID, ADDRESS_ID, IS_ACTIVE, DW_CREATE_DATE)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.first_name,
    c.last_name,
    c.email,
    c.store_id,
    c.address_id,
    c.active AS is_active,
    CURRENT_TIMESTAMP() AS dw_create_date
FROM SAKILA_PROD.STG.STG_CUSTOMER c;

-- =========================================================
-- 3. DIM_RENTAL (Adding the Unknown Member: RENTAL_KEY = -1)
-- =========================================================
CREATE OR REPLACE TABLE DIM_RENTAL (
    RENTAL_KEY NUMBER(38,0) PRIMARY KEY, -- Removed IDENTITY to manually insert -1
    RENTAL_ID NUMBER(38,0),
    INVENTORY_ID NUMBER(38,0),
    CUSTOMER_ID NUMBER(38,0),
    RENTAL_DATE TIMESTAMP_NTZ(9),
    RETURN_DATE TIMESTAMP_NTZ(9),
    STAFF_ID NUMBER(38,0),
    DW_CREATE_DATE TIMESTAMP_NTZ(9)
);

-- Insert the 'Unknown Member' record first
INSERT INTO DIM_RENTAL (RENTAL_KEY, RENTAL_ID, INVENTORY_ID, CUSTOMER_ID, RENTAL_DATE, RETURN_DATE, STAFF_ID, DW_CREATE_DATE)
VALUES (-1, -1, -1, -1, NULL, NULL, -1, CURRENT_TIMESTAMP());

-- Insert the actual data using a sequence or high number for SKs
INSERT INTO DIM_RENTAL (RENTAL_KEY, RENTAL_ID, INVENTORY_ID, CUSTOMER_ID, RENTAL_DATE, RETURN_DATE, STAFF_ID, DW_CREATE_DATE)
SELECT 
    ROW_NUMBER() OVER (ORDER BY r.rental_id) + 1 AS rental_key, -- Assigning a positive SK starting from 1 (or 2)
    r.rental_id,
    r.inventory_id,
    r.customer_id,
    r.rental_date,
    r.return_date,
    r.staff_id,
    CURRENT_TIMESTAMP() AS dw_create_date
FROM SAKILA_PROD.STG.STG_RENTAL r;


-- =========================================================
-- 4. DIM_DATE (No change to CREATE/INSERT - Retains DATE_KEY SK)
-- =========================================================
CREATE OR REPLACE TABLE DIM_DATE (
    DATE_KEY NUMBER(8,0) PRIMARY KEY,
    DATE_FULL DATE,
    YEAR NUMBER(4,0),
    MONTH_NUM NUMBER(2,0),
    MONTH_NAME VARCHAR(15),
    DAY_OF_MONTH NUMBER(2,0),
    DAY_OF_WEEK_NUM NUMBER(1,0),
    DAY_OF_WEEK_NAME VARCHAR(15),
    IS_WEEKEND BOOLEAN
);

INSERT INTO DIM_DATE (DATE_KEY, DATE_FULL, YEAR, MONTH_NUM, MONTH_NAME, DAY_OF_MONTH, DAY_OF_WEEK_NUM, DAY_OF_WEEK_NAME, IS_WEEKEND)
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(p.payment_date, 'YYYYMMDD')) AS date_key,
    TO_DATE(p.payment_date) AS date_full,
    YEAR(p.payment_date) AS year,
    MONTH(p.payment_date) AS month_num,
    TO_CHAR(p.payment_date, 'MMMM') AS month_name,
    DAY(p.payment_date) AS day_of_month,
    DAYOFWEEK(p.payment_date) AS day_of_week_num,
    DAYNAME(p.payment_date) AS day_of_week_name,
    CASE WHEN DAYOFWEEK(p.payment_date) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM SAKILA_PROD.STG.STG_PAYMENT p;


-- =========================================================
-- 5. FACT_PAYMENT (FIXED: Using LEFT JOIN and COALESCE for RENTAL_KEY)
-- =========================================================
CREATE OR REPLACE TABLE FACT_PAYMENT AS
SELECT 
    p.payment_id,
    
    -- FIXED: Use LEFT JOIN and COALESCE to assign -1 if no RENTAL_KEY is found.
    COALESCE(dd.date_key, -1) AS PAYMENT_DATE_KEY,    
    COALESCE(dc.customer_key, -1) AS CUSTOMER_KEY,     
    COALESCE(dr.rental_key, -1) AS RENTAL_KEY,          -- Primary Fix
    
    p.staff_id AS STAFF_NATURAL_ID,
    
    -- Measures
    p.amount,
    
    -- Transaction Time
    p.payment_date
    
FROM SAKILA_PROD.STG.STG_PAYMENT p
-- Use LEFT JOINs to ensure all 1000 rows from STG_PAYMENT are preserved
LEFT JOIN DWH.DIM_CUSTOMER dc
    ON p.customer_id = dc.customer_id
LEFT JOIN DWH.DIM_RENTAL dr
    ON p.rental_id = dr.rental_id
LEFT JOIN DWH.DIM_DATE dd
    ON TO_DATE(p.payment_date) = dd.date_full;


-- =========================================================
-- 6. Verification Queries (FACT_PAYMENT count will now be 1000)
-- =========================================================
SELECT COUNT(*) AS dim_customer_count FROM DIM_CUSTOMER;
SELECT COUNT(*) AS dim_rental_count FROM DIM_RENTAL;
SELECT COUNT(*) AS dim_date_count FROM DIM_DATE;
SELECT COUNT(*) AS fact_payment_count FROM FACT_PAYMENT; 
-- This count should now be 1000, assuming no other joins were causing losses.