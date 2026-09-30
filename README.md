# Snowflake Vegetable Data Pipeline

An end-to-end Snowflake data pipeline project demonstrating data ingestion, staging, transformation, and querying using Snowflake.

## Project Overview

This project demonstrates a workflow for loading a local CSV dataset into Snowflake and transforming the data for analysis.

The pipeline follows this workflow:

**Local CSV → Internal Stage → File Format → COPY INTO → Snowflake Table → Transformations → Views**

The project uses vegetable and root-depth data to demonstrate core Snowflake data warehousing concepts.

## Technologies

- Snowflake
- SQL
- CSV
- GitHub

## Snowflake Concepts Demonstrated

- Databases and schemas
- Snowflake-managed internal stages
- Named file formats
- CSV data ingestion
- `COPY INTO`
- Querying staged files
- Load verification
- SQL joins
- Common Table Expressions (CTEs)
- Aggregations
- Views

## Data Pipeline

### 1. Data Staging

A Snowflake-managed internal stage is used to store the CSV file before loading it into a Snowflake table.

### 2. File Format

A reusable CSV file format defines how Snowflake should interpret the source file, including:

- Comma delimiter
- Header row handling
- Optionally enclosed fields

### 3. Data Loading

The `COPY INTO` command loads the staged CSV data into the destination Snowflake table.

### 4. Data Validation

The loaded data is validated using SQL queries and row counts.

### 5. Data Transformation

SQL joins are used to combine vegetable data with root-depth information.

CTEs and aggregations are used to organize queries, filter results, and summarize the dataset.

### 6. Views

A reusable Snowflake view provides a simplified way to access the transformed vegetable and root-depth data without repeatedly writing the underlying join.

## Example Transformation

```sql
SELECT
    v.PLANT_NAME,
    v.ROOT_DEPTH_CODE,
    r.ROOT_DEPTH_NAME
FROM VEGETABLE_DETAILS AS v
INNER JOIN ROOT_DEPTH AS r
    ON v.ROOT_DEPTH_CODE = r.ROOT_DEPTH_CODE;
