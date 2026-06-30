--1. Completed rides per driver — name and count, descending.
SELECT
	d.name,
	count(status) AS completed_rides
FROM
	trips t
JOIN drivers d ON
	t.driver_id = d.driver_id
AND 
	status = 'completed'
GROUP BY
	d.name
ORDER BY
	completed_rides DESC;


--2. Drivers with NO completed rides. (LEFT JOIN + NULL check.)
SELECT
	d.driver_id,
	d.name
FROM
	drivers d
LEFT JOIN trips t
    ON
	d.driver_id = t.driver_id
	AND t.status = 'completed'	-- filters BEFORE joining
WHERE
	t.trip_id IS NULL         -- keeps only unmatched drivers


-- 3. Average fare per pickup city, descending.
SELECT
	l.city_name pickup_city,
	round(avg(t.fare_amount), 2) AS avg_fare
FROM
	trips t
JOIN locations l ON
	t.pickup_location_id = l.location_id
GROUP BY
	l.city_name
ORDER BY
	avg_fare DESC;

---4. Rides where pickup and dropoff city are the same.
SELECT
	t.trip_id,
	pickup.city_name pickup_city,
	dropoff.city_name dropoff_city
FROM
	trips t
JOIN locations pickup ON
	t.pickup_location_id = pickup.location_id
JOIN locations dropoff ON
	t.dropoff_location_id = dropoff.location_id
WHERE
	t.pickup_location_id = t.dropoff_location_id;

-- 5. What is the total fare collected across completed rides only?
--previously
SELECT
	sum(r.fare_amount)
FROM
	rides r
WHERE
	ride_status = 'completed'; 
--new schema
SELECT
	sum(t.fare_amount) total_fare
FROM
	trips t
WHERE
	t.status = 'completed'; 