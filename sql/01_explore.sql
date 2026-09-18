-- 20556 · Mandag · Version 1.0
-- =========================================================================
-- Antal rækker i datasættet
SELECT COUNT(*) AS total_antal_raekker
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- Undersøg schema/datatyper (DuckDB-specifik funktion)
DESCRIBE
SELECT *
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- Lille udsnit af data (Her bruger vi LIMIT!)
SELECT *
FROM 'data/raw/yellow_tripdata_2025-01.parquet'
LIMIT 5;
-- Tjek perioden i pickup-tidsstemplet (Min og Max dato)
SELECT MIN(tpep_pickup_datetime) AS foerste_opsamling,
    MAX(tpep_pickup_datetime) AS seneste_opsamling
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- Forskellige pickup-lokationer (Unikke ID'er)
SELECT COUNT(DISTINCT PULocationID) AS unikke_opsamlings_zoner
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- Spørgsmål: Hvilke betalingstyper (payment_type) giver de største drikkepenge (tip_amount) i gennemsnit?
SELECT payment_type,
    COUNT(*) AS antal_ture,
    ROUND(AVG(tip_amount), 2) AS gns_drikkepenge,
    ROUND(AVG(fare_amount), 2) AS gns_tur_pris
FROM 'data/raw/yellow_tripdata_2025-01.parquet'
GROUP BY payment_type
ORDER BY gns_drikkepenge DESC;
-- Vi undersøger relationen via et JOIN mellem taxiture og zonefilen.
-- Vi bruger et LEFT JOIN for at kontrollere, om der er taxiture med et PULocationID, der mangler i zonefilen.
SELECT z.Borough AS opsamlings_bydel,
    COUNT(t.VendorID) AS antal_ture,
    ROUND(AVG(t.trip_distance), 2) AS gns_distance
FROM 'data/raw/yellow_tripdata_2025-01.parquet' AS t
    LEFT JOIN 'data/raw/taxi_zone_lookup.csv' AS z ON t.PULocationID = z.LocationID
GROUP BY z.Borough
ORDER BY antal_ture DESC;
