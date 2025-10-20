-- Set the role with the necessary permissions (e.g., SYSADMIN)
USE ROLE SYSADMIN; 

-- -------------------------------------------------------------------
-- 1. ENVIRONMENT SETUP
-- -------------------------------------------------------------------

-- Specify the compute warehouse to be used for the operations
USE WAREHOUSE SAKILA_WH; 

-- Create the main production database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS SAKILA_PROD
COMMENT = 'Main database for the Sakila data analytics project.';

-- Switch context to the newly created database
USE DATABASE SAKILA_PROD;

-- -------------------------------------------------------------------
-- 2. SCHEMA CREATION (Medallion Architecture)
-- -------------------------------------------------------------------

-- a) LND (Landing/BRONZE) Schema:
-- Stores raw, unmodified data ingested directly from external sources.
CREATE SCHEMA IF NOT EXISTS LND
COMMENT = 'BRONZE Layer: Contains raw, source-system-fidelity data tables and associated external/internal stages.';

-- b) STG (Staging/SILVER) Schema:
-- Holds cleaned, standardized, and integrated data ready for dimensional modeling.
CREATE SCHEMA IF NOT EXISTS STG
COMMENT = 'SILVER Layer: Stores intermediate tables (staging) after initial cleaning, data type enforcement, and deduplication.';

-- c) DWH (Data Warehouse/GOLD) Schema:
-- Houses the final dimensional model (Fact and Dimension tables) optimized for analytics.
CREATE SCHEMA IF NOT EXISTS DWH
COMMENT = 'GOLD Layer: Contains the final Fact and Dimension tables ready for consumption by BI tools and end-users.';

---
-- -------------------------------------------------------------------
-- 3. DATA LOADING SETUP (Stage and File Format)
-- -------------------------------------------------------------------

-- Switch context to the LND schema where loading objects are defined
USE SCHEMA LND; 

-- Define a File Format object for the CSV files
CREATE FILE FORMAT IF NOT EXISTS SAKILA_CSV_FORMAT
TYPE = CSV                      -- Specifies the file type
FIELD_DELIMITER = ','           -- Specifies the column delimiter
SKIP_HEADER = 1                 -- Skips the first row (header) in the file
NULL_IF = ('', 'NULL')          -- Treats empty strings and 'NULL' text as actual SQL NULLs
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE -- Allows loading even if the column count is slightly off (can be set to TRUE for stricter checks)
COMMENT = 'Standard CSV file format definition for the Sakila raw data ingestion.';

-- Create an Internal Named Stage (Snowflake's internal cloud storage)
-- This stage will be used as a temporary holding area for the CSV files before loading them into LND tables.
CREATE STAGE IF NOT EXISTS SAKILA_RAW_INTERNAL_STAGE
FILE_FORMAT = SAKILA_CSV_FORMAT -- Links the Stage to the File Format definition
COMMENT = 'Internal Stage for uploading raw CSV files via SnowSQL PUT command.';