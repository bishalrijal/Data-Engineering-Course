---Week 2 Assignment

---Normalization

---seperate table for location

CREATE TABLE locations (
    location_id  serial PRIMARY KEY, 
    city_name varchar(100) NOT NULL UNIQUE 
);

---seperate table for drivers

CREATE TABLE drivers (
driver_id serial PRIMARY KEY,
driver_name varchar (100) NOT NULL 
);

---seperate table for passenger

CREATE TABLE passengers(
passenger_id serial PRIMARY KEY ,
passenger_name varchar (100) NOT NULL
);

---seperate table for payment method

CREATE TABLE payment_methods(
payment_method_id serial PRIMARY KEY,
method_name varchar (30) NOT NULL 
);

---seperate table for whole trips

CREATE TABLE trips(
    trip_id              serial        PRIMARY KEY,
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


---inserting values into table

INSERT INTO drivers(driver_name)
SELECT
DISTINCT initcap (trim(regexp_replace(r.driver_name, '\s+',' ','g')))
FROM rides r;




INSERT INTO passengers(passenger_name)
SELECT 
DISTINCT initcap (trim (regexp_replace(r.passenger_name, '\s+',' ', 'g')))
FROM rides r;


INSERT INTO payment_methods(method_name)
SELECT 
DISTINCT payment_method FROM rides
WHERE payment_method IS NOT NULL ;



INSERT INTO locations( city_name)

SELECT DISTINCT (pickup_city) FROM rides r
UNION 
SELECT DISTINCT (dropoff_city) FROM rides r;


---before inserting into trips table we will check each table

SELECT 
	(SELECT  driver_id 
		FROM drivers d 
	 WHERE d.driver_name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id
, *
	 FROM rides r;



SELECT 
	(SELECT  passenger_id 
		FROM passengers p
	 WHERE p.passenger_name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id
, *
	 FROM rides r;

SELECT * FROM passengers p;




SELECT (SELECT location_id
FROM locations p 
WHERE p.city_name = r.pickup_city) pickup_location_id,
*
FROM rides r;




SELECT (SELECT payment_method_id
FROM payment_methods p 
WHERE p.method_name = r.payment_method) payment_method_id, *
FROM rides r;


---now inserting all values into trips table

INSERT INTO trips (
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
	(SELECT  driver_id 
	FROM drivers d 
	 WHERE d.driver_name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
(SELECT  passenger_id 
		FROM passengers p
	 WHERE p.passenger_name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.pickup_city ) pickup_location_id,
(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.dropoff_city ) dropoff_location_id,
fare_amount,
ride_distance_km,
ride_status,
requested_at,
completed_at,
rating,
(SELECT  payment_method_id  
		FROM payment_methods pm  
		WHERE pm.method_name = r.payment_method  ) payment_method_id
FROM rides r;

 