INSERT
	INTO
	payment_methods(name)
SELECT
	DISTINCT payment_methods
FROM
	rides
WHERE
	payment_methods IS NOT NULL;