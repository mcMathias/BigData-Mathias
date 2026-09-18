-- Grain for dette aggregat: Én række pr. pickup-zone og ugedag.
CREATE OR REPLACE TABLE agg_zone_daily AS
SELECT 
    z.borough,
    z.zone AS pickup_zone,
    d.day_name,
    d.day_of_week,
    -- Beregninger / Measures
    COUNT(f.trip_id) AS antal_ture,
    SUM(f.total_amount) AS samlet_omsætning,
    AVG(f.total_amount) AS gns_omsætning,
    AVG(f.trip_distance) AS gns_distance,
    AVG(f.tip_amount) AS gns_drikkepenge
FROM fact_trip f
JOIN dim_zone z ON f.pickup_location_id = z.location_id
JOIN dim_date d ON f.pickup_date = d.date_actual
GROUP BY z.borough, z.zone, d.day_name, d.day_of_week;


SELECT 
    borough,
    SUM(antal_ture) AS total_ture_i_bydel,
    SUM(samlet_omsætning) AS samlet_omsætning_i_bydel,
    -- Korrekt gen-aggregering af gennemsnit ved hjælp af de gemte tællere:
    SUM(samlet_omsætning) / SUM(antal_ture) AS sandt_gns_omsætning
FROM agg_zone_daily
GROUP BY borough
ORDER BY samlet_omsætning_i_bydel DESC;