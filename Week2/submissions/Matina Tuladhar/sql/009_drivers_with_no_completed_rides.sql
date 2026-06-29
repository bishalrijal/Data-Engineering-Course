-- Drivers with NO completed rides. (LEFT JOIN + NULL check.)
SELECT
	d.driver_id ,
	d.name AS driver_name
FROM
	drivers d
LEFT JOIN trips t
ON
	d.driver_id = t.driver_id
	AND t.status = 'completed'
WHERE
	t.driver_id IS NULL;
