---Cities that appear as pickup or dropoff locations
CREATE TABLE locations(
    location_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL UNIQUE
);

--- Drivers (Canonical names, deduped from the flat table)
CREATE TABLE drivers(
    driver_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

--- Passenger
CREATE TABLE passengers(
    passenger_id SERIAL PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL
);

CREATE TABLE payment_methods (
	payment_method_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE 
);
