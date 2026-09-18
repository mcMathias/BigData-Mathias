-- 20556 · Tirsdag · Version 1.2
-- Arbejdsfil: dimensions
--
-- Formål:
--   Byg de dimensioner, som fact_trip skal kunne referere til.
--   Bevar raw-input uændret.
--
-- Arbejd i denne rækkefølge:
--   1. Kontrollér de rå kilder.
--   2. Byg dim_zone.
--   3. Kontrollér at zone-nøglen er entydig.
--   4. Byg dim_date, så den dækker både pickup- og dropoff-datoer.
--   5. Kontrollér at date-nøglen er entydig og dækker begge roller.
--
-- TODO: Implementér dim_zone.
-- Krav:
--   - én række pr. LocationID
--   - brugbare attributter til analyse, fx Borough, Zone og service_zone
--   - en tydelig nøgle, som fact_trip kan referere til

-- Opret dim_zone ud fra den rå zone-lookup fil
CREATE OR REPLACE TABLE dim_zone AS
SELECT 
    CAST(LocationID AS INTEGER) AS location_id,
    Borough AS borough,
    Zone AS zone,
    service_zone AS service_zone
FROM 'data/raw/taxi_zone_lookup.csv';

-- TODO: Kontrollér dim_zone.
-- Vis fx antal rækker og antal unikke zone-nøgler.

-- Kontrollér antal rækker og unikke nøgler i dim_zone
SELECT 
    COUNT(*) AS total_rækker,
    COUNT(DISTINCT location_id) AS unikke_lokationer
FROM dim_zone;
-- Hvis de to tal er helt ens, er nøglen 100% entydig!

-- TODO: Implementér dim_date.
-- Krav:
--   - én række pr. dato
--   - datoer fra både tpep_pickup_datetime og tpep_dropoff_datetime
--   - brugbare attributter til analyse, fx år, måned, dag og ugedag

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

-- TODO: Kontrollér dim_date.
-- Vis fx antal rækker, antal unikke datoer og min/max dato.
-- Undersøg også om alle pickup/dropoff-datoer i raw-data findes i dim_date.

-- Kontrollér dim_date (min/max dato og antal rækker)
SELECT 
    COUNT(*) AS antal_datoer,
    MIN(date_actual) AS foerste_dato,
    MAX(date_actual) AS sidste_dato
FROM dim_date;


