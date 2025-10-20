-- Assuming the necessary warehouse and schema setup is complete.
USE WAREHOUSE SAKILA_WH;
USE DATABASE SAKILA_PROD;
USE SCHEMA DWH; -- Assuming DWH is the schema where the final tables reside

---------------------------------------------------------
-- 1. Monthly Revenue Calculation
-- Objective: Calculates the total revenue (SUM(AMOUNT)) for
--            each year and month by joining FACT_PAYMENT to DIM_DATE.
---------------------------------------------------------
SELECT
    dd.YEAR,
    dd.MONTH_NUM,  -- Using MONTH_NUM for proper ordering
    SUM(fp.AMOUNT) AS monthly_revenue
FROM
    FACT_PAYMENT fp
JOIN
    DIM_DATE dd ON fp.PAYMENT_DATE_KEY = dd.DATE_KEY -- FIXED: Joining via Surrogate Key (DATE_KEY)
GROUP BY
    dd.YEAR,
    dd.MONTH_NUM
ORDER BY
    dd.YEAR,
    dd.MONTH_NUM;

---
---------------------------------------------------------
-- 2. Top Customers by Revenue
-- Objective: Lists the top 10 customers based on their highest total spending,
--            using the Surrogate Key relationship between Fact and Dimension.
---------------------------------------------------------
SELECT
    dc.FULL_NAME, -- Using the denormalized FULL_NAME for cleaner output
    SUM(fp.AMOUNT) AS total_spending
FROM
    FACT_PAYMENT fp
JOIN
    DIM_CUSTOMER dc ON fp.CUSTOMER_KEY = dc.CUSTOMER_KEY -- FIXED: Joining via Surrogate Key (CUSTOMER_KEY)
GROUP BY
    dc.CUSTOMER_KEY, dc.FULL_NAME
ORDER BY
    total_spending DESC
LIMIT 10;


---------------------------------------------------------
-- 3. Revenue Comparison: Weekend vs. Weekday
-- Objective: Determine if the business generates significantly more revenue
--            on weekends (Saturday/Sunday) to optimize staffing/marketing.
---------------------------------------------------------
SELECT
    CASE 
        WHEN dd.IS_WEEKEND = TRUE THEN 'Weekend'
        ELSE 'Weekday'
    END AS time_period,
    SUM(fp.AMOUNT) AS total_revenue,
    COUNT(fp.payment_id) AS total_transactions
FROM
    FACT_PAYMENT fp
JOIN
    DIM_DATE dd ON fp.PAYMENT_DATE_KEY = dd.DATE_KEY
GROUP BY
    time_period
ORDER BY
    total_revenue DESC;

---------------------------------------------------------
-- 4. Revenue by Staff Member (Employee Performance)
-- Objective: Measure the direct revenue contribution of each staff member
--            for performance evaluation and incentive planning.
---------------------------------------------------------
-- NOTE: A full model would include a DIM_STAFF and join on STAFF_KEY.
-- Since DIM_STAFF is not built, we use the Natural Key (STAFF_NATURAL_ID).
SELECT
    fp.STAFF_NATURAL_ID,
    SUM(fp.AMOUNT) AS revenue_generated,
    COUNT(fp.payment_id) AS transactions_processed
FROM
    FACT_PAYMENT fp
GROUP BY
    fp.STAFF_NATURAL_ID
ORDER BY
    revenue_generated DESC;    