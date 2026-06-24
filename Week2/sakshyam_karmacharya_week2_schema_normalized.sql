-- week2_queries.sql
-- Week 2 Assignment
-- Submit file:
--    <your_name>week2_schema_normalized.sql  (your CREATE TABLE + INSERT migration)

-- Drop tables if they already exist
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS payment_methods;

-- Create locations table
CREATE TABLE locations (
location_id SERIAL PRIMARY KEY,
city_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create drivers table
CREATE TABLE drivers (
driver_id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL
);

-- Create passengers table
CREATE TABLE passengers (
passenger_id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL
);

-- Create payment methods table
CREATE TABLE payment_methods (
payment_method_id SERIAL PRIMARY KEY,
name VARCHAR(30) NOT NULL UNIQUE
);

-- Create trips table with foreign keys
CREATE TABLE trips (
trip_id SERIAL PRIMARY KEY,
driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
passenger_id INTEGER NOT NULL REFERENCES passengers(passenger_id),
pickup_location_id INTEGER NOT NULL REFERENCES locations(location_id),
dropoff_location_id INTEGER NOT NULL REFERENCES locations(location_id),
fare_amount NUMERIC(10,2) NOT NULL CHECK (fare_amount > 0),
distance_km NUMERIC(6,2) NOT NULL,
status VARCHAR(50) NOT NULL CHECK (status IN ('completed', 'cancelled', 'no_show')),
requested_at TIMESTAMP NOT NULL,
completed_at TIMESTAMP,
rating NUMERIC(2,1),
payment_method_id INTEGER REFERENCES payment_methods(payment_method_id)
);

-- Insert cleaned driver data
INSERT INTO drivers (name)
SELECT DISTINCT INITCAP(TRIM(REGEXP_REPLACE(driver_name, '\s+', ' ', 'g')))
FROM rides;

-- Insert cleaned passenger data
INSERT INTO passengers (name)
SELECT DISTINCT INITCAP(TRIM(REGEXP_REPLACE(passenger_name, '\s+', ' ', 'g')))
FROM rides;

-- Insert unique locations from pickup and dropoff
INSERT INTO locations (city_name)
SELECT DISTINCT pickup_city FROM rides
UNION
SELECT DISTINCT dropoff_city FROM rides;

-- Insert payment methods (excluding nulls)
INSERT INTO payment_methods (name)
SELECT DISTINCT payment_method
FROM rides
WHERE payment_method IS NOT NULL;

-- Insert normalized trip data
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
(SELECT driver_id FROM drivers d WHERE d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))),
(SELECT passenger_id FROM passengers p WHERE p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))),
(SELECT location_id FROM locations l WHERE l.city_name = r.pickup_city),
(SELECT location_id FROM locations l WHERE l.city_name = r.dropoff_city),
r.fare_amount,
r.ride_distance_km,
r.ride_status,
r.requested_at,
r.completed_at,
r.rating,
(SELECT payment_method_id FROM payment_methods pm WHERE pm.name = r.payment_method)
FROM rides r;

-- Basic verification
SELECT COUNT(*) FROM rides;
SELECT COUNT(*) FROM trips;
SELECT * FROM trips LIMIT 10;
