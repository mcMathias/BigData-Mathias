
-- Opret dim_zone ud fra den rå zone-lookup fil
CREATE OR REPLACE TABLE dim_zone AS
SELECT 
    CAST(LocationID AS INTEGER) AS location_id,
    Borough AS borough,
    Zone AS zone,
    service_zone AS service_zone
FROM 'data/raw/taxi_zone_lookup.csv';

-- Kontrollér antal rækker og unikke nøgler i dim_zone
SELECT 
    COUNT(*) AS total_rækker,
    COUNT(DISTINCT location_id) AS unikke_lokationer
FROM dim_zone;

-- Opret dim_date ved at samle alle unikke datoer fra både pickup og dropoff
CREATE OR REPLACE TABLE dim_date AS
WITH all_dates AS (
    SELECT CAST(tpep_pickup_datetime AS DATE) AS dtk FROM 'data/raw/yellow_tripdata_2025-01.parquet'
    UNION
    SELECT CAST(tpep_dropoff_datetime AS DATE) AS dtk FROM 'data/raw/yellow_tripdata_2025-01.parquet'
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY dtk) AS date_id, -- Teknisk primærnøgle
    dtk AS date_actual,
    EXTRACT(YEAR FROM dtk) AS year,
    EXTRACT(MONTH FROM dtk) AS month,
    EXTRACT(DAY FROM dtk) AS day,
    EXTRACT(DAYOFWEEK FROM dtk) AS day_of_week, -- 0 eller 1-7 afhængigt af indstilling
    STRFTIME(dtk, '%A') AS day_name
FROM all_dates
WHERE dtk IS NOT NULL;

-- Kontrollér dim_date (min/max dato og antal rækker)
SELECT 
    COUNT(*) AS antal_datoer,
    MIN(date_actual) AS foerste_dato,
    MAX(date_actual) AS sidste_dato
FROM dim_date;


