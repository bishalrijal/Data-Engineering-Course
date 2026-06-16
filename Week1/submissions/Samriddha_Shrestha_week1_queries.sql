-- week1_queries.sql
-- Week 1 Assignment
-- Submit this file with all 8 queries filled in.
-- Label each query clearly. Add a comment if your answer
-- reveals something interesting about the data.
--
-- Grading: correctness + NULL handling + clean formatting
-- Due: before Week 2, Day 1

-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

-- YOUR QUERY HERE
SELECT count(*) 
FROM rides;

-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

-- YOUR QUERY HERE
SELECT DISTINCT pickup_city 
FROM rides 
ORDER BY pickup_city;


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

-- YOUR QUERY HERE
SELECT * 
FROM rides
WHERE fare_amount > 500
ORDER BY fare_amount DESC;

-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?

-- YOUR QUERY HERE
SELECT count(*) 
FROM rides 
WHERE rating IS NULL;


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

-- YOUR QUERY HERE
SELECT * 
FROM rides
WHERE ride_status = 'completed'
ORDER BY requested_at DESC
LIMIT 10;

-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

-- YOUR QUERY HERE
SELECT ride_status, 
    count(*) AS num_rides
FROM rides
GROUP BY ride_status;

-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

-- YOUR QUERY HERE
SELECT sum(fare_amount) AS total_fare
FROM rides
WHERE ride_status = 'completed';    

-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

-- YOUR QUERY HERE
SELECT count(*) AS num_same_city_rides
FROM rides
WHERE pickup_city = dropoff_city;