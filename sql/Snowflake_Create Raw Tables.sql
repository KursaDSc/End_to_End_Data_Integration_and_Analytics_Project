-- =========================================================
-- USE warehouse, database, and LND schema (BRONZE layer)
-- =========================================================
USE WAREHOUSE SAKILA_WH;
USE DATABASE SAKILA_PROD;
-- Veri alımını (RAW data loading) LND şemasında yapıyoruz.
USE SCHEMA LND; 

-- NOT: Bu kodun çalışması için, Stage objesinin (SAKILA_RAW_INTERNAL_STAGE) 
-- ve File Format objesinin (SAKILA_CSV_FORMAT) LND şemasında önceden oluşturulmuş olması gerekir.
-- Stage yolu artık SAKILA_PROD.LND.SAKILA_RAW_INTERNAL_STAGE şeklinde olmalıdır.

-- =========================================================
-- 1️⃣ T_CUSTOMER_LND TABLE (Replaces RAW_CUSTOMER)
-- =========================================================
-- T_customer_LND (Tablo adlandırmasını T_VARLIK_LND olarak güncelledik)
CREATE OR REPLACE TABLE T_CUSTOMER_LND (
    customer_id INTEGER,
    store_id INTEGER,
    first_name STRING,
    last_name STRING,
    email STRING,
    address_id INTEGER,
    active BOOLEAN,
    create_date TIMESTAMP,
    last_update TIMESTAMP
);

COPY INTO T_CUSTOMER_LND
-- Stage yolu, LND şeması içindeki Stage'i işaret etmelidir.
FROM @SAKILA_PROD.LND.SAKILA_RAW_INTERNAL_STAGE/customer.csv
-- Sadece TYPE ve SKIP_HEADER kullanılarak, daha önce tanımlanan FILE_FORMAT objesini kullanmak daha temizdir.
-- Ancak kodunuzdaki inline tanıma sadık kalarak FIELD_OPTIONALLY_ENCLOSED_BY parametresini koruduk.
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER = 1);

---
-- =========================================================
-- 2️⃣ T_PAYMENT_LND TABLE (Replaces RAW_PAYMENT)
-- =========================================================
-- T_PAYMENT_LND (Tablo adlandırmasını T_VARLIK_LND olarak güncelledik)
CREATE OR REPLACE TABLE T_PAYMENT_LND (
    payment_id INTEGER,
    customer_id INTEGER,
    staff_id INTEGER,
    rental_id INTEGER,
    amount FLOAT,
    payment_date TIMESTAMP,
    last_update TIMESTAMP
);

COPY INTO T_PAYMENT_LND
FROM @SAKILA_PROD.LND.SAKILA_RAW_INTERNAL_STAGE/payment.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER = 1);

---
-- =========================================================
-- 3️⃣ T_RENTAL_LND TABLE (Replaces RAW_RENTAL)
-- =========================================================
-- T_RENTAL_LND (Tablo adlandırmasını T_VARLIK_LND olarak güncelledik)
CREATE OR REPLACE TABLE T_RENTAL_LND (
    rental_id INTEGER,
    rental_date TIMESTAMP,
    inventory_id INTEGER,
    customer_id INTEGER,
    return_date TIMESTAMP,
    staff_id INTEGER,
    last_update TIMESTAMP
);

COPY INTO T_RENTAL_LND
FROM @SAKILA_PROD.LND.SAKILA_RAW_INTERNAL_STAGE/rental.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER = 1);

---
-- =========================================================
-- 4️⃣ Get loaded row counts (LND Şeması içinde)
-- =========================================================
SELECT COUNT(*) AS customer_lnd_rows FROM T_CUSTOMER_LND;
SELECT COUNT(*) AS payment_lnd_rows FROM T_PAYMENT_LND;
SELECT COUNT(*) AS rental_lnd_rows FROM T_RENTAL_LND;