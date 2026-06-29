--Average fare per pickup city, descending.
SELECT
	t.pickup_location_id,
	l.city_name,
	ROUND(AVG(t.fare_amount), 2) AS average_fare
FROM
	trips t
JOIN locations l
ON
	l.location_id = t.pickup_location_id
GROUP BY
	t.pickup_location_id,
	l.city_name
ORDER BY
	average_fare DESC;