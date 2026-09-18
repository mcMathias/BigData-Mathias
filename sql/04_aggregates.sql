-- 20556 · Onsdag · Version 1.0
-- Arbejdsfil: aggregates
--
-- Formål:
--   Byg et aggregat ud fra den analytiske model for at undersøge, 
--   hvad der sker ved sammenfatning af data.

-- TODO: Byg et relevant aggregate ud fra den analytiske model.
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


-- TODO: Undersøg, hvad der sker, hvis resultatet aggregeres endnu en gang.
-- Eksempel: Aggregér vores allerede opsummerede tabel op til et overordnet niveau pr. bydel (Borough).
-- Bemærk: Hvis vi vil finde det sande gennemsnit på tværs igen, kan vi ikke bare tage AVG(gns_omsætning), 
-- da zonerne har forskelligt antal ture. Vi skal bruge de bevarede tællere (antal_ture og samlet_omsætning)!
SELECT 
    borough,
    SUM(antal_ture) AS total_ture_i_bydel,
    SUM(samlet_omsætning) AS samlet_omsætning_i_bydel,
    -- Korrekt gen-aggregering af gennemsnit ved hjælp af de gemte tællere:
    SUM(samlet_omsætning) / SUM(antal_ture) AS sandt_gns_omsætning
FROM agg_zone_daily
GROUP BY borough
ORDER BY samlet_omsætning_i_bydel DESC;