-- All Tasks and Key Observations

-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT
	COUNT(*) AS total_rides
FROM
	rides;

-- There are 5002 total rides in the dataset.

-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT
	DISTINCT pickup_city AS pickup_cities
FROM
	rides
ORDER BY
	pickup_cities;

-- Observations: 

-- Most pickup locations are from developed cities.
-- However some cities like Dharan, Bharatpur and Dhangadi are still missing which could be potential areas for expansion.

-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT
	*
FROM
	rides
WHERE
	fare_amount > 500
ORDER BY
	fare_amount DESC;

-- Observations: 

-- There is no clear correlation between ride distance and fare amount. 
-- Further indepth analysis reveal that fare amount has no clear relation with other fields/multiple combination of fields like pickup and drop location, order date and time.
-- Fare amount seems to be randomly generated field.

-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?

SELECT COUNT(*)
FROM rides 
WHERE rating IS NULL

-- Observations: 

-- Out of 5002 total rides, 2379 (47.5%) contains null rating. Almost 50% rides having null rating is bit high. 
-- If most of it is driven by ride being cancelled, then the problem of high cancellation rate needs to be solved with highest priority.


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides

SELECT * 
FROM rides 
WHERE ride_status = 'completed'
ORDER BY requested_at DESC 
LIMIT 10;

-- Recent ratings are severely low. Only three out of last 10 rides have 4+ rating and 4 out of 10 rides have less than 3 rating.
-- All rides have been intercity rides with 6 of them covering 20+ kilometers and 4 of them covering 30+ kilometers.


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.

SELECT ride_status, count(*) AS total_counts
FROM rides
GROUP BY ride_status;

-- 43% incomplete rate is alarming and are mostly driven by cancellations (28% of total) and no show (15% of total).
-- Close to 43% of business potential is being lost due to these two factors alone. 


-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT
	sum(fare_amount)
FROM
	rides
WHERE
	ride_Status = 'completed';


-- With only 57% completion rate, total of 1,429,830.36 fare has been collected from completed rides only.
-- If the completion rate was had been 80%, fare amount of close to 2,000,000 could have been collected with growth of around 38%.



-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

SELECT
	*
FROM
	rides
WHERE
	pickup_city = dropoff_city;
    
-- There are total of 192 rides where pickup_city and dropoff_city are the same. 
-- Many ride distances in cities like lalitpur and bhaktapur are higher than 40 kilometers which seems unlikely.
-- Specifically ride_id 384 having ride distance of 41.2 kilometers was completed in 27 minutes within lalitpur city. 
-- This means he was riding at the average speed of 91 km/hr which is highly unlikely within city like lalitpur.
