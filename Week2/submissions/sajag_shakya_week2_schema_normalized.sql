-- week2_queries.sql
-- Week 2 Assignment

				-- TABLE DEFINITIONS (DDL) --
-- locations table
CREATE TABLE locations( 
	location_id 	serial 			PRIMARY KEY,
	city_name 		varchar(100) 	NOT NULL UNIQUE
);

-- drivers table
CREATE TABLE drivers( 
	driver_id		serial 			PRIMARY KEY, 
	name 			varchar(100) 	NOT NULL
);

-- passenger table
CREATE TABLE passengers (
    passenger_id     	SERIAL        PRIMARY KEY,
    name          		VARCHAR(100)  NOT NULL
);

-- payment_methods table
CREATE TABLE payment_methods (
	payment_method_id		SERIAL 		PRIMARY KEY,
	name VARCHAR(30)		NOT NULL 	UNIQUE 
);

--create table trips with FK, central table that links all entities via FK
CREATE TABLE trips (
    trip_id              SERIAL        PRIMARY KEY,
    driver_id            INTEGER       NOT NULL REFERENCES drivers(driver_id),
    passenger_id         INTEGER       NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id   INTEGER       NOT NULL REFERENCES locations(location_id),
    dropoff_location_id  INTEGER       NOT NULL REFERENCES locations(location_id),
    fare_amount          NUMERIC(10,2) NOT NULL CHECK (fare_amount > 0),
    distance_km          NUMERIC(6,2)  NOT NULL,
    status               varchar(50)   NOT NULL CHECK (status IN ('completed','cancelled','no_show')),
    requested_at         TIMESTAMP     NOT NULL,
    completed_at         TIMESTAMP,
    rating               NUMERIC(2,1)  CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id    INTEGER       REFERENCES payment_methods(payment_method_id)
);

---------------------------------------------------------------------------------------------------------------------------

-- DATA CLEANING PART: FIXING THE INCONSISTENCIES SUCH AS WHITESPACES, CASE INCONSISTENCUES, USING trim, regexp_replace, initcap
SELECT DISTINCT driver_name
FROM
rides r
WHERE
driver_name LIKE '%  %';

SELECT trim(' sajag shakya ');
---sajag shakya

SELECT
	DISTINCT REPLACE(driver_name, '  ', ' ')
FROM
	rides r;

SELECT
	DISTINCT lower(REPLACE(driver_name, '  ', ' '))
FROM
	rides r; 

SELECT
	DISTINCT initcap(REPLACE(driver_name, '  ', ' '))
FROM
	rides r; 

SELECT ('Sajag		Shakya');
SELECT regexp_replace('Sajag 		Shakya','\s+',' ','g'); --regexp_replace is more robust

SELECT
	DISTINCT initcap(trim(regexp_replace(r.driver_name, '\s+', ' ', 'g')))
FROM
	rides r;

INSERT
	INTO
	drivers(name)
SELECT
	DISTINCT initcap(trim(regexp_replace(r.driver_name, '\s+', ' ', 'g'))) FROM rides r;

SELECT * FROM drivers;
------------------------------------------------------------------------------------------------------------------
-- MIGRATING DATA FROM RAW RIDES TABLE TO NORMALIZED TABLES
INSERT
	INTO
	passengers(name)
SELECT
	DISTINCT initcap(trim(regexp_replace(r.passenger_name, '\s+', ' ', 'g'))) FROM rides r;

SELECT * FROM passengers;

--------------------------------------------------------------------------------------------
INSERT
	INTO
	locations(city_name)
SELECT
	DISTINCT pickup_city
FROM
	rides r
UNION 
SELECT
	DISTINCT dropoff_city
FROM
	rides r; -- Combine pickup and dropoff cities; UNION removes duplicates

SELECT * FROM locations;
--------------------------------------------------------------------------------------------


INSERT
	INTO
	payment_methods(name) 
SELECT
	DISTINCT payment_method
FROM
	rides
WHERE
	payment_method IS NOT NULL; -- Exclude NULL payment methods, in payment_methods table, NULL is not needed...
								--if a payment method is null, it can be seen in the main table

SELECT * FROM payment_methods;

--------------------------------------------------------------------------------
-- VERIFY SUBQUERIES 
SELECT 
	(
	SELECT
		driver_id
	FROM
		drivers d
	WHERE
		d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
	*
FROM
	rides r;


SELECT 
	(
	SELECT
		passenger_id
	FROM
		passengers p
	WHERE
		p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
	*
FROM
	rides r;

-- INSERTING INTO TRIPS TABLE
INSERT
	INTO
	trips (
	driver_id,
	passenger_id,
	pickup_location_id,
	dropoff_location_id,
	fare_amount,
	distance_km,
	status,
	requested_at,
	completed_at,
	rating,
	payment_method_id
)
SELECT
	(
	SELECT
		driver_id
	FROM
		drivers d
	WHERE
		d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
	(
	SELECT
		passenger_id
	FROM
		passengers p
	WHERE
		p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
	(
	SELECT
		location_id
	FROM
		locations p
	WHERE
		p.city_name = r.pickup_city ) pickup_location_id,
	(
	SELECT
		location_id
	FROM
		locations p
	WHERE
		p.city_name = r.dropoff_city ) dropoff_location_id,
	fare_amount,
	ride_distance_km,
	ride_status,
	requested_at,
	completed_at,
	rating,
	(
	SELECT
		payment_method_id
	FROM
		payment_methods pm
	WHERE
		pm.name = r.payment_method ) payment_method_id
FROM
	rides r;

SELECT * FROM trips;
SELECT * FROM drivers;
SELECT * FROM locations;
SELECT * FROM passengers;
SELECT * FROM payment_methods;


---Join examples
--get trip details with driver names
SELECT
	t.trip_id, d.driver_id ,
	d.name AS driver_name,
	t.fare_amount
FROM
	trips t
INNER JOIN drivers d ON
	t.driver_id = d.driver_id ;

-- All trips, even those with no payment method recorded
SELECT 
    t.trip_id,
    t.fare_amount,
    pm.name      AS payment_method
FROM trips t
LEFT JOIN payment_methods pm ON t.payment_method_id = pm.payment_method_id;
