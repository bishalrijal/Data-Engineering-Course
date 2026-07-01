--Drop all the existing tables (clean setup)

DROP TABLE IF EXISTS trips CASCADE ;
DROP TABLE IF EXISTS drivers CASCADE ;
DROP TABLE IF EXISTS passengers CASCADE;
DROP TABLE IF EXISTS locations CASCADE ;
DROP TABLE IF EXISTS payment_methods CASCADE ;

--Create lookup tables
--Cities that appear as pickup or dropoff locations
CREATE TABLE locations(
	location_id SERIAL PRIMARY KEY,
	city_name VARCHAR(100) NOT NULL UNIQUE 
	);

--Drivers dedupliacted and cleaned from the flat rides table
CREATE TABLE drivers(
	driver_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
	);

--Passengers dedupliacted and cleaned from the flat rides table
CREATE TABLE passengers(
	passenger_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL 
	);

--Payment methods (cash, esewa, card, etc.)
CREATE TABLE payment_methods(
	payment_methods_id SERIAL PRIMARY KEY,
	name VARCHAR(25) NOT NULL UNIQUE
	);


--CREATE the trips table

CREATE TABLE trips(
	trips_id serial PRIMARY KEY,
	driver_id integer NOT NULL REFERENCES drivers(driver_id),
	passenger_id integer NOT NULL REFERENCES passengers(passenger_id),
	pickup_location_id integer NOT NULL REFERENCES locations(location_id),
	dropoff_location_id integer NOT NULL REFERENCES locations(location_id),
	fare_amount numeric(10,2) NOT NULL CHECK(fare_amount >0),
	distance_km numeric(6,2) NOT NULL ,
	status varchar(50) NOT NULL CHECK (status IN ('completed','cancelled','no_show')),
	requested_at timestamp NOT NULL,
	completed_at timestamp ,
	rating numeric(2,1) CHECK (rating BETWEEN 1.0 AND 5.0),
	payment_methods_id integer REFERENCES payment_methods(payment_methods_id)
	);

--Insert data from rides into lookup tables
--Insert unique, cleaned driver names
INSERT INTO drivers (name)
SELECT DISTINCT 
	initcap(TRIM(regexp_replace(driver_name,'\s+',' ','g')))
FROM rides;

--Insert unique, cleaned passenger names
INSERT INTO passengers(name)
SELECT DISTINCT 
	initcap(TRIM(regexp_replace(passenger_name,'\s+',' ','g')))
FROM rides;

--Insert all unique cities (pickup + dropoff combined)
--Union automatically removes duplicates across both colums
INSERT INTO locations(city_name)
SELECT DISTINCT pickup_city FROM rides
UNION 
SELECT DISTINCT dropoff_city FROM rides;

--Insert unique payment methods(skip null)
INSERT INTO payment_methods(name)
SELECT DISTINCT payment_method
FROM  rides
WHERE payment_method IS NOT NULL;

--insert into trips
INSERT INTO trips(
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
	payment_methods_id
	)
SELECT 
--lookup driver_id using cleaned name
	(
	SELECT driver_id
	FROM drivers d 
	WHERE d.name= initcap(TRIM(regexp_replace(r.driver_name,'\s+',' ','g')))
	) AS driver_id,
	
--lookup passenger_id using cleaned name
	(
	SELECT passenger_id
	FROM passengers p 
	WHERE p.name= initcap(TRIM(regexp_replace(r.passenger_name,'\s+',' ','g')))
	) AS passenger_id,
	
--lookup pickup_location_id using cleaned name
	(
	SELECT location_id
	FROM locations l
	WHERE l.city_name = r.pickup_city

	) AS pickup_location_id,
	
--lookup dropoff_location_id using cleaned name
	
	(
	SELECT location_id
	FROM locations l 
	WHERE l.city_name = r.dropoff_city
	) AS dropoff_location_id,
	
	r.fare_amount,
	r.ride_distance_km,
	r.ride_status,
	r.requested_at,
	r.completed_at,
	r.rating,
	
--lookup payment_method_id (can be null if payment_method is null)
	(
	SELECT payment_methods_id
	FROM payment_methods pm 
	WHERE pm.name= r.payment_method
	) AS payment_methods_id
	
FROM rides r;
	

--To confirm everything migrated corrected

SELECT 'drivers' AS table_name, count(*) AS row_count FROM drivers d 
UNION ALL 
SELECT 'passengers', count(*) FROM passengers p 
UNION ALL 
SELECT 'locations', count(*) FROM locations l 
UNION ALL 
SELECT 'payment_methods',count(*) FROM payment_methods pm 
UNION ALL 
SELECT 'trips', count(*) FROM trips t ;





