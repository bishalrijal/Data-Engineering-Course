-- ── Week1_Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?
SELECT
    SUM(fare_amount) AS total_completed_fare,
    COUNT(*) AS completed_rides,
    COUNT(fare_amount) AS rides_with_fare_recorded
FROM
    trips
WHERE
    status = 'completed';

-- Total fare collected from completed rides is 1,430,112.40.
-- Both COUNT(*) and COUNT(fare_amount) return 2862, meaning no fare
-- values are NULL i.e., the SUM is complete and no revenue data is missing.

-- ── Schema Migration Verification ─────────────────────────────────
-- Same query on the original denormalized rides table to verify data parity.
-- Note: ride_status is used here instead of status.
SELECT
    SUM(fare_amount) AS total_completed_fare,
    COUNT(*) AS completed_rides,
    COUNT(fare_amount) AS rides_with_fare_recorded
FROM
    rides
WHERE
    ride_status = 'completed';

-- Both queries return 1,430,112.40 and 2862 — data is consistent across tables.