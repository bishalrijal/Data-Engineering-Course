-- week1_queries.sql
-- Week 1 Assignment


-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?
SELECT
    COUNT(*) AS total_rides
FROM
    rides;


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.
SELECT DISTINCT
    pickup_city
FROM
    rides
ORDER BY
    pickup_city;


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.
SELECT
    ride_id,
    fare_amount,
    pickup_city,
    dropoff_city,
    requested_at
FROM
    rides
WHERE
    fare_amount > 500
ORDER BY
    fare_amount DESC;

-- We can see that all of this data is from the 'requested_at' year : 2024.


-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
SELECT
    COUNT(*) AS null_rated_rides
FROM
    rides
WHERE
    rating IS NULL;

-- A NULL rating most likely means the passenger did not rate the driver
-- after the ride. It can also mean the ride was never completed i.e.,
-- a cancelled, no_show, or pending ride would naturally have no rating
-- since the journey never happened.
-- We can also see that almost 50% of the data in our dataset has NULL rating which means
-- that maximum passengers do not rate the driver.


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).
SELECT
    ride_id,
    completed_at,
    fare_amount,
    pickup_city
FROM
    rides
WHERE
    ride_status = 'completed'
ORDER BY
    completed_at DESC
LIMIT
    10;

-- The question is asking about recently COMPLETED rides, hence, the 'completed_at' column has been used instead of 'requested_at'.
-- The output shows that most recently completed rides include their 'pickup_city' as 'Chitwan'.


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
SELECT
    ride_status,
    COUNT(*) AS num_of_rides_per_status
FROM
    rides
GROUP BY
    ride_status;

-- We can see that most of the rides have been completed which is a good sign from business point of view.


-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?
SELECT
    SUM(fare_amount) AS total_completed_fare,
    COUNT(*) AS completed_rides,
    COUNT(fare_amount) AS rides_with_fare_recorded
FROM
    rides
WHERE
    ride_status = 'completed';

-- Total fare collected from completed rides is 1,430,112.40.
-- Both COUNT(*) and COUNT(fare_amount) return 2862, meaning no fare
-- values are NULL i.e., the SUM is complete and no revenue data is missing.


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? 
SELECT
    COUNT(*) AS same_city_rides
FROM
    rides
WHERE
    pickup_city = dropoff_city
    OR (
        pickup_city IS NULL
        AND dropoff_city IS NULL
    );

-- Same pickup and dropoff city could sometimes be legitimate
-- (e.g. a round trip, or a very short ride within the same city zone).
-- However, rows where both pickup_city AND dropoff_city are NULL
-- are likely missing data caused by a system error or incomplete booking
-- and should be treated as invalid.
-- Worth investigating before using this data for any analysis.