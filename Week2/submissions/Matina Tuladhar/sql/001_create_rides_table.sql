DROP TABLE IF EXISTS rides;

CREATE TABLE rides (
    ride_id SERIAL PRIMARY KEY,
    driver_name VARCHAR(250) NOT NULL,
    passenger_name VARCHAR(250) NOT NULL,
    pickup_city VARCHAR(250) NOT NULL,
    dropoff_city VARCHAR(250) NOT NULL,
    fare_amount NUMERIC(10, 2) NOT NULL CHECK (fare_amount >= 0),
    ride_distance NUMERIC(6, 2) NOT NULL CHECK (ride_distance >= 0),
    ride_status VARCHAR(25) NOT NULL DEFAULT 'pending' CHECK (
        ride_status IN (
            'cancelled',
            'completed',
            'no_show',
            'pending'
        )
    ),
    requested_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    rating NUMERIC(2, 1) NULL CHECK (
        rating >= 1.0
        AND rating <= 5.0
    ),
    payment_methods VARCHAR(100) NULL CHECK (
        payment_methods IN (
            'card',
            'cash',
            'esewa',
            'khalti'
        )
    )
);

COPY rides FROM '/data/rides.csv' CSV HEADER NULL '';