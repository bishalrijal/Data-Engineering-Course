INSERT
	INTO
	passengers(name)
SELECT
	DISTINCT INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))
FROM
	rides r;
