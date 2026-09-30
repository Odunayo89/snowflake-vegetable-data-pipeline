-- ============================================================
-- SNOWFLAKE HANDS-ON PRACTICE
-- Data Loading, Querying, and Transformations
-- ============================================================
-- Database: GARDEN_PLANTS
-- Schema:   VEGGIES
--
-- Topics:
--   1. Internal stages
--   2. File formats
--   3. COPY INTO
--   4. Querying staged data
--   5. Joins
--   6. Common Table Expressions (CTEs)
--   7. Aggregations
--   8. Views
-- ============================================================


-- ============================================================
-- PART 1: DATA LOADING
-- STAGES, FILE FORMATS, AND COPY INTO
-- ============================================================
-- Objective:
-- Load a local CSV file into Snowflake using an internal
-- named stage, a reusable file format, and COPY INTO.
--
-- Workflow:
-- Local CSV -> Internal Stage -> File Format -> COPY INTO -> Table
-- ============================================================


-- ------------------------------------------------------------
-- 1. Set Database and Schema Context
-- ------------------------------------------------------------

USE DATABASE GARDEN_PLANTS;
USE SCHEMA VEGGIES;


-- ------------------------------------------------------------
-- 2. Create a Snowflake-Managed Internal Stage
-- ------------------------------------------------------------
-- Purpose:
-- A stage provides a location where Snowflake can store
-- or access files before loading them into a table.
--
-- Note:
-- VEGGIE_STAGE was created through the Snowflake UI.
-- The SQL equivalent is shown below.

CREATE STAGE IF NOT EXISTS GARDEN_PLANTS.VEGGIES.VEGGIE_STAGE;


-- ------------------------------------------------------------
-- 3. Upload CSV File
-- ------------------------------------------------------------
-- The CSV file was uploaded from the local computer into
-- VEGGIE_STAGE using the Snowflake interface.


-- ------------------------------------------------------------
-- 4. Inspect Files in the Stage
-- ------------------------------------------------------------

LIST @GARDEN_PLANTS.VEGGIES.VEGGIE_STAGE;


-- ------------------------------------------------------------
-- 5. Create a Reusable File Format
-- ------------------------------------------------------------
-- Purpose:
-- Define how Snowflake should interpret the CSV file.

CREATE FILE FORMAT IF NOT EXISTS
    GARDEN_PLANTS.VEGGIES.VEGGIE_CSV_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';


-- ------------------------------------------------------------
-- 6. Inspect File Format Settings
-- ------------------------------------------------------------

DESC FILE FORMAT GARDEN_PLANTS.VEGGIES.VEGGIE_CSV_FORMAT;


-- ------------------------------------------------------------
-- 7. Query the Staged File Before Loading
-- ------------------------------------------------------------
-- $1 and $2 represent the first and second fields in the file.

SELECT
    $1 AS PLANT_NAME,
    $2 AS ROOT_DEPTH_CODE
FROM @GARDEN_PLANTS.VEGGIES.VEGGIE_STAGE
(
    FILE_FORMAT => 'GARDEN_PLANTS.VEGGIES.VEGGIE_CSV_FORMAT'
);


-- ------------------------------------------------------------
-- 8. Load Staged Data into the Destination Table
-- ------------------------------------------------------------

COPY INTO GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS
FROM @GARDEN_PLANTS.VEGGIES.VEGGIE_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'GARDEN_PLANTS.VEGGIES.VEGGIE_CSV_FORMAT'
);


-- ------------------------------------------------------------
-- 9. Verify Loaded Data
-- ------------------------------------------------------------

SELECT *
FROM GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;


-- ------------------------------------------------------------
-- 10. Verify Row Count
-- ------------------------------------------------------------

SELECT COUNT(*) AS ROW_COUNT
FROM GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;


-- ------------------------------------------------------------
-- Key Concepts
-- ------------------------------------------------------------
-- Stage:
--   A location where Snowflake stores or accesses files.
--
-- File Format:
--   Defines how Snowflake interprets the structure of a file.
--
-- COPY INTO:
--   Loads data from staged files into a Snowflake table.
--
-- LIST:
--   Displays files available in a stage.
--
-- Internal Stage:
--   Files are stored in Snowflake-managed storage.
--
-- External Stage:
--   Files remain in external cloud storage such as AWS S3,
--   Azure Blob Storage, or Google Cloud Storage.
--
-- Load History:
--   Snowflake tracks file-loading metadata, helping prevent
--   accidental duplicate loading of the same file.


-- ============================================================
-- PART 2: QUERYING AND DATA TRANSFORMATIONS
-- JOINS, CTEs, AGGREGATIONS, AND VIEWS
-- ============================================================
-- Objective:
-- Query and transform data already stored in Snowflake by
-- combining related tables, creating reusable intermediate
-- result sets, aggregating data, and creating views.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Set Database and Schema Context
-- ------------------------------------------------------------

USE DATABASE GARDEN_PLANTS;
USE SCHEMA VEGGIES;


-- ------------------------------------------------------------
-- 2. Inspect Available Tables
-- ------------------------------------------------------------

SHOW TABLES IN SCHEMA GARDEN_PLANTS.VEGGIES;


-- ------------------------------------------------------------
-- 3. Inspect Source Data
-- ------------------------------------------------------------

SELECT *
FROM VEGETABLE_DETAILS
LIMIT 5;

SELECT *
FROM ROOT_DEPTH;


-- ============================================================
-- EXERCISE 1: JOIN
-- ============================================================
-- Question:
-- Join VEGETABLE_DETAILS and ROOT_DEPTH using ROOT_DEPTH_CODE.
-- Return the plant name, root depth code, and root depth name.
-- ============================================================

SELECT
    v.PLANT_NAME,
    v.ROOT_DEPTH_CODE,
    r.ROOT_DEPTH_NAME
FROM VEGETABLE_DETAILS AS v
INNER JOIN ROOT_DEPTH AS r
    ON v.ROOT_DEPTH_CODE = r.ROOT_DEPTH_CODE;


-- ============================================================
-- EXERCISE 2: CTE WITH JOIN AND FILTERING
-- ============================================================
-- Question:
-- Create a CTE called deep_root_plants.
-- Join VEGETABLE_DETAILS and ROOT_DEPTH using ROOT_DEPTH_CODE.
-- Return PLANT_NAME, ROOT_DEPTH_CODE, and ROOT_DEPTH_NAME.
-- In the main query, return only plants whose
-- ROOT_DEPTH_NAME is 'Deep'.
-- ============================================================

WITH deep_root_plants AS (
    SELECT
        v.PLANT_NAME,
        v.ROOT_DEPTH_CODE,
        r.ROOT_DEPTH_NAME
    FROM VEGETABLE_DETAILS AS v
    INNER JOIN ROOT_DEPTH AS r
        ON v.ROOT_DEPTH_CODE = r.ROOT_DEPTH_CODE
)

SELECT
    PLANT_NAME,
    ROOT_DEPTH_CODE,
    ROOT_DEPTH_NAME
FROM deep_root_plants
WHERE ROOT_DEPTH_NAME = 'Deep';


-- ============================================================
-- EXERCISE 3: CTE WITH AGGREGATION
-- ============================================================
-- Question:
-- Create a CTE called root_summary.
-- Group vegetables by ROOT_DEPTH_CODE.
-- Count the number of plants in each group and name the
-- resulting column PLANT_COUNT.
-- Return only groups where PLANT_COUNT is greater than 3.
-- ============================================================

WITH root_summary AS (
    SELECT
        ROOT_DEPTH_CODE,
        COUNT(PLANT_NAME) AS PLANT_COUNT
    FROM VEGETABLE_DETAILS
    GROUP BY ROOT_DEPTH_CODE
)

SELECT
    ROOT_DEPTH_CODE,
    PLANT_COUNT
FROM root_summary
WHERE PLANT_COUNT > 3;


-- ============================================================
-- EXERCISE 4: CREATE A VIEW
-- ============================================================
-- Question:
-- Create a reusable view that combines vegetable information
-- with descriptive root-depth information.
--
-- A standard view stores the query definition rather than
-- creating another physical copy of the underlying table data.
-- ============================================================

CREATE OR REPLACE VIEW VEGETABLE_ROOT_DETAILS AS
SELECT
    v.PLANT_NAME,
    v.ROOT_DEPTH_CODE,
    r.ROOT_DEPTH_NAME
FROM VEGETABLE_DETAILS AS v
INNER JOIN ROOT_DEPTH AS r
    ON v.ROOT_DEPTH_CODE = r.ROOT_DEPTH_CODE;


-- ------------------------------------------------------------
-- Query the View
-- ------------------------------------------------------------

SELECT *
FROM VEGETABLE_ROOT_DETAILS;


-- ------------------------------------------------------------
-- Filter Data Through the View
-- ------------------------------------------------------------

SELECT *
FROM VEGETABLE_ROOT_DETAILS
WHERE ROOT_DEPTH_NAME = 'Deep';


-- ============================================================
-- KEY CONCEPTS LEARNED
-- ============================================================
-- JOIN:
--   Combines related rows from multiple tables using a
--   common field.
--
-- CTE:
--   Creates a temporary named result set that exists for
--   the duration of a SQL statement.
--
-- Aggregation:
--   Summarizes multiple rows using operations such as COUNT,
--   SUM, AVG, MIN, and MAX.
--
-- View:
--   Stores a reusable SQL query definition that can be queried
--   similarly to a table.
--
-- Overall workflow:
--   Raw Data -> Stage -> Table -> Join/Transform -> View -> Analysis
-- ============================================================