
-- Week 2 Assignment: Schema Normalization

--   Migrate the flat denormalized `rides` table into a normalized schema (3NF) consisting of 5 tables:
--   drivers, passengers, locations, payment_methods, trips.

--reset and rerun
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS drivers;


-- DRIVERS
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    name      VARCHAR(100) NOT NULL UNIQUE
);


-- PASSENGERS
CREATE TABLE passengers (
    passenger_id SERIAL PRIMARY KEY,
    name         VARCHAR(30) NOT NULL UNIQUE
);


-- LOCATIONS
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    city_name   VARCHAR(100) NOT NULL UNIQUE
);


-- PAYMENT METHODS
CREATE TABLE payment_methods (
    payment_method_id SERIAL PRIMARY KEY,
    name              VARCHAR(30) NOT NULL UNIQUE
);


-- TRIPS
-- Central table that records each ride.
-- Stores only IDs — no repeated text values.
-- All foreign keys reference their dimension tables.

CREATE TABLE trips (
    trip_id             SERIAL PRIMARY KEY,
    driver_id           INTEGER        NOT NULL REFERENCES drivers(driver_id),
    passenger_id        INTEGER        NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id  INTEGER        NOT NULL REFERENCES locations(location_id),
    dropoff_location_id INTEGER        NOT NULL REFERENCES locations(location_id),
    fare_amount         NUMERIC(10, 2) NOT NULL CHECK (fare_amount > 0),
    distance_km         NUMERIC(6, 2)  NOT NULL,
    status              VARCHAR(50)    NOT NULL CHECK (status IN ('completed', 'cancelled', 'no_show')),
    requested_at        TIMESTAMP      NOT NULL,
    completed_at        TIMESTAMP,
    rating              NUMERIC(2, 1)  CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id   INTEGER        REFERENCES payment_methods(payment_method_id)
);


-- Before inserting, we apply these string cleaning steps:
--
--   REGEXP_REPLACE(name, '\s+', ' ', 'g'): collapses multiple spaces into one
--   TRIM(...):  removes leading and trailing spaces
--   INITCAP(...):  capitalizes the first letter of each word
--
-- Combining all three: INITCAP(TRIM(REGEXP_REPLACE(...))) produces clean, consistent values for every name.

-- Insert distinct cleaned driver names
INSERT INTO drivers (name)
SELECT DISTINCT
    INITCAP(TRIM(REGEXP_REPLACE(driver_name, '\s+', ' ', 'g')))
FROM rides;


-- Insert distinct cleaned passenger names
INSERT INTO passengers (name)
SELECT DISTINCT
    INITCAP(TRIM(REGEXP_REPLACE(passenger_name, '\s+', ' ', 'g')))
FROM rides;


-- Insert distinct cities from both pickup AND dropoff columns
--     UNION (not UNION ALL) removes cities that appear in both columns
--     vertically stacks the two sets of distinct cities into one set of unique cities

INSERT INTO locations (city_name)
SELECT DISTINCT
    INITCAP(TRIM(REGEXP_REPLACE(pickup_city, '\s+', ' ', 'g')))
FROM rides
UNION
SELECT DISTINCT
    INITCAP(TRIM(REGEXP_REPLACE(dropoff_city, '\s+', ' ', 'g')))
FROM rides;


-- Insert distinct payment methods (exclude NULL values)
INSERT INTO payment_methods (name)
SELECT DISTINCT payment_method
FROM rides
WHERE payment_method IS NOT NULL;


-- Insert into trips table and subquery the other tables to look up the corresponding IDs for each ride.
--  for every row in rides, we need to translate text → ID. That translation is done using a correlated subquery.
-- a correlated subquery is a select inside another select , the inner select runs once for every row of outer select


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
    -- look up driver ID by matching cleaned name 
    -- here d.name is from drivers table and r.driver_name is from rides table, we are matching them after cleaning the names
    (SELECT driver_id
     FROM drivers d
     WHERE d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g'))))
     AS driver_id,

    -- look up passenger ID by matching cleaned name
    (SELECT passenger_id
     FROM passengers p
     WHERE p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g'))))
     AS passenger_id,

    -- look up pickup city ID
    (SELECT location_id
    FROM locations l
    WHERE l.city_name = INITCAP(TRIM(REGEXP_REPLACE(r.pickup_city, '\s+', ' ', 'g'))))
    AS pickup_location_id,

    -- look up dropoff city ID  
    (SELECT location_id
    FROM locations l
    WHERE l.city_name = INITCAP(TRIM(REGEXP_REPLACE(r.dropoff_city, '\s+', ' ', 'g'))))
    AS dropoff_location_id,

    fare_amount,
    ride_distance_km  AS distance_km,
    ride_status       AS status,
    requested_at,
    completed_at,
    rating,

    -- look up payment method ID (NULL safe — returns NULL if no match)
    (SELECT payment_method_id
     FROM payment_methods pm
     WHERE pm.name = r.payment_method) 
     AS payment_method_id

FROM rides r;
