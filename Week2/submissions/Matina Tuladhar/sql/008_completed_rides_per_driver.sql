-- Completed rides per driver — name and count, descending.
SELECT
	d.name AS driver_name,
	COUNT(trip_id) AS trip_count
FROM
	drivers d
LEFT JOIN trips t
ON
	d.driver_id = t.driver_id
	AND t.status = 'completed'
GROUP BY
	d.driver_id,
	d.name
ORDER BY
	COUNT(trip_id) DESC;