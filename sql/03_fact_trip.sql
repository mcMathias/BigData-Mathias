CREATE OR REPLACE TABLE fact_trip AS
SELECT 
    -- Unik rækkenøgle (teknisk ID til tabellen)
    ROW_NUMBER() OVER () AS trip_id,
    
    -- Fremmednøgler til zoner (Role-playing: Pickup og Dropoff)
    CAST(PULocationID AS INTEGER) AS pickup_location_id,
    CAST(DOLocationID AS INTEGER) AS dropoff_location_id,
    
    -- Fremmednøgler til datoer (Role-playing: Pickup og Dropoff dato)
    CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
    CAST(tpep_dropoff_datetime AS DATE) AS dropoff_date,
    
    -- Originale tidsstempler
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    
    -- Measures (Målinger)
    passenger_count,
    trip_distance,
    fare_amount,
    tip_amount,
    tolls_amount,
    total_amount,
    payment_type
FROM 'data/raw/yellow_tripdata_2025-01.parquet';


SELECT 
    (SELECT COUNT(*) FROM 'data/raw/yellow_tripdata_2025-01.parquet') AS antal_raw,
    (SELECT COUNT(*) FROM fact_trip) AS antal_fact;


SELECT 
    'Manglende pickup-zone' AS tjek,
    COUNT(*) AS antal 
FROM fact_trip f
LEFT JOIN dim_zone z ON f.pickup_location_id = z.location_id
WHERE z.location_id IS NULL

UNION ALL

SELECT 
    'Manglende dropoff-zone',
    COUNT(*) 
FROM fact_trip f
LEFT JOIN dim_zone z ON f.dropoff_location_id = z.location_id
WHERE z.location_id IS NULL

UNION ALL

SELECT 
    'Manglende pickup-dato',
    COUNT(*) 
FROM fact_trip f
LEFT JOIN dim_date d ON f.pickup_date = d.date_actual
WHERE d.date_actual IS NULL

UNION ALL

SELECT 
    'Manglende dropoff-dato',
    COUNT(*) 
FROM fact_trip f
LEFT JOIN dim_date d ON f.dropoff_date = d.date_actual
WHERE d.date_actual IS NULL;


SELECT COUNT(f.trip_id) AS antal_med_zone_join
FROM fact_trip f
JOIN dim_zone z_pu ON f.pickup_location_id = z_pu.location_id
JOIN dim_zone z_do ON f.dropoff_location_id = z_do.location_id;



SELECT 
    z.borough,
    z.zone AS pickup_zone,
    COUNT(f.trip_id) AS antal_ture,
    ROUND(AVG(f.tip_amount), 2) AS gns_drikkepenge,
    ROUND(AVG(f.trip_distance), 2) AS gns_distance
FROM fact_trip f
JOIN dim_zone z ON f.pickup_location_id = z.location_id
GROUP BY z.borough, z.zone
ORDER BY gns_drikkepenge DESC
LIMIT 10;

SELECT 
    d.day_name,
    COUNT(f.trip_id) AS antal_ture,
    ROUND(AVG(f.fare_amount), 2) AS gns_pris
FROM fact_trip f
JOIN dim_date d ON f.pickup_date = d.date_actual
GROUP BY d.day_name, d.day_of_week
ORDER BY d.day_of_week;