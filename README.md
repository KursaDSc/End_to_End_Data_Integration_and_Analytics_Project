# 🎬 Azure Data Engineering & Analytics – Week 7
## End-to-End Data Integration & Analytics Project
*(MySQL → Snowflake → MongoDB)*

---

## 📌 Project Overview

This project demonstrates a full data lifecycle using the Sakila film rental dataset. It shows how data moves between three environments and how each platform supports different parts of a modern analytics pipeline:

- MySQL (Relational / OLTP)
- Snowflake (Cloud Data Warehouse / OLAP)
- MongoDB (NoSQL Document Store)

Key activities:
- Data modeling (ERD & star schema)
- Data extraction, transformation, and loading (ETL / ELT)
- Analytical queries and reporting
- Document modeling and aggregation in NoSQL

---

## 🎯 Goal

Migrate and analyze the Sakila dataset across MySQL, Snowflake, and MongoDB while practicing:
- Database design and modeling
- ETL workflows and data staging
- Cloud data warehousing and analytics
- NoSQL document modeling and aggregations

---

## 🏗️ Architecture

MySQL (Relational OLTP)
  ↓ Export CSV
Snowflake (Cloud DW / OLAP)
  ↓ Transform & Query (Star Schema)
MongoDB (NoSQL Document Store)

---

## 🚦 Project Phases

### Phase 1 — MySQL (OLTP)
Objective: Install Sakila, explore the schema, create an ERD, and export source tables.

Tasks:
- Import `sakila-schema.sql` and `sakila-data.sql` into MySQL Workbench.
- Inspect tables and relationships; produce an ERD.
- Write and run SQL queries (examples: top 10 films, rentals by country).
- Export key tables (customer, rental, payment) to CSV files.

Deliverables:
- ERD diagram (PNG/PDF)
- SQL query screenshots
- Exported CSV files

---

### Phase 2 — Snowflake (Cloud Data Warehouse)
Objective: Load the CSV exports into Snowflake, design a star schema, and run analytical queries.

Tasks:
- Create Snowflake account, warehouse, database and schema.
- Upload CSVs to a Snowflake stage and use COPY INTO to load tables.
- Design a star schema with a fact table and supporting dimensions.
- Run analytical queries (monthly revenue, top countries, top films).

Deliverables:
- Star schema diagram
- Snowflake SQL scripts and screenshots
- Results of 3+ analytical queries

Suggested star schema:
- Fact table: fact_payments (rental_id, customer_id, store_id, film_id, rental_date, return_date, payment_amount, ...)
- Dimension tables: dim_customer, dim_date, dim_rental

---

### Phase 3 — MongoDB (NoSQL)
Objective: Model the data as documents and run aggregation queries in MongoDB Atlas.

Tasks:
- Provision a MongoDB Atlas cluster and connect using Compass.
- Import CSVs into collections using mongoimport or Compass.
- Design document models (embedding vs referencing) for customers, rentals and payments.
- Create indexes to speed common queries.
- Implement aggregation pipelines (rentals per country, total payments per customer, monthly trends).

Deliverables:
- JSON document examples
- Aggregation queries and results
- Index definitions

---

## 🧰 Tools & Resources

- MySQL Workbench: https://dev.mysql.com/downloads/workbench
- Snowflake: https://signup.snowflake.com
- MongoDB Atlas: https://www.mongodb.com/atlas
- MongoDB Compass: https://www.mongodb.com/products/compass

---

## 🚀 Quick Start / How to Run

1. MySQL
   - Import schema and data:
     - Run `sakila-schema.sql` then `sakila-data.sql` in MySQL Workbench.
   - Export CSVs (example):
     - SELECT ... INTO OUTFILE 'customer.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM customer;

2. Snowflake
   - Create a stage: `CREATE STAGE my_stage;`
   - Upload files: `PUT file://path/customer.csv @my_stage;`
   - Load into table:
     `COPY INTO schema.table FROM @my_stage/customer.csv FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER = 1);`

3. MongoDB
   - Import CSV to a collection:
     `mongoimport --uri "<CONNECTION_URI>" --collection customers --type csv --headerline --file customer.csv`

4. Analytics
   - Run Snowflake analytics queries in a worksheet.
   - Use MongoDB Compass or aggregation pipelines for NoSQL queries.

---

## 📦 Repository Layout (suggested)

- /docs/ERD/ — ERD diagrams (PNG/PDF)
- /sql/ — SQL scripts (MySQL & Snowflake)
- /mysql/ — Exported CSVs (customer.csv, rental.csv, payment.csv)
- /mongo/ — MongoDB import, aggregation and query scripts
- /screenshots/ — Process screenshots as PPTX file

---

## 📊 Example Analyses

- Monthly revenue report (Snowflake): revenue grouped by month/year.
- Top 10 films by rental count and by revenue.
- Total payments by country (MongoDB aggregation).
- Customer lifetime value approximations based on payments and rentals.

(Screenshots and query outputs are included in /screenshots/.)

---

## 🔍 Reflection (short)
This project highlights the complementary roles of OLTP, OLAP, and NoSQL systems. MySQL enforces relational integrity and excels at transactional workloads. Snowflake provides scalable, high-performance analytics and simplifies star schema reporting. MongoDB offers flexible document modeling that benefits hierarchical or frequently changing data structures. Combining these platforms enables robust transactional processing, efficient analytical queries, and flexible operational reporting in real-world data architectures.

---

## ✉️ Contact & License

Author: KursaDSc  
License: MIT

---
