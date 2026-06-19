-- Student Name: Aditya Shanker Shrestha
-- Week 2: Normalizing the flat rides table into 3NF
-- Entities: locations, drivers, passengers, payment_methods, trips
-- Cleaning: initcap + trim + regexp_replace for consistent dedup
-- Verified: 5000 rows preserved, end-to-end joins reconstruct original data
-- Cleaning and normalizing rides

-- Creating tables for normalization. In order for table data dependencies due to foreign key usages.

-- Locations Table
create table locations(
	location_id SERIAL primary key, 
 	city_name varchar(100) unique not null
 );

-- Drivers Table

create table drivers(
	driver_id SERIAL primary key,
	driver_name VARCHAR(100) not null 
);

-- Passenger Table
create table passengers (
	passenger_id SERIAL primary key,
	passenger_name VARCHAR(100) not null 
);

-- Payment Methods Table

create table payment_methods (
	payment_method_id SERIAL primary key,
	payment_method_name VARCHAR(100) unique not null 
);

-- Trips table
CREATE TABLE trips (
    trip_id              SERIAL        PRIMARY KEY,
    driver_id            INTEGER       NOT NULL REFERENCES drivers(driver_id),
    passenger_id         INTEGER       NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id   INTEGER       NOT NULL REFERENCES locations(location_id),
    dropoff_location_id  INTEGER       NOT NULL REFERENCES locations(location_id),
    fare_amount          NUMERIC(10,2) NOT NULL CHECK (fare_amount > 0),
    distance_km          NUMERIC(6,2)  NOT null CHECK(distance_km >= 0),
    status               varchar(50)   NOT NULL CHECK (status IN ('completed','cancelled','no_show')),
    requested_at         TIMESTAMP     NOT NULL,
    completed_at         TIMESTAMP,
    rating               NUMERIC(2,1)  CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id    INTEGER       REFERENCES payment_methods(payment_method_id)
);

-- Inserting cleaned data ( by using initcap/trim/regexp_replace for data consitency ) into drivers table.

insert into drivers  (driver_name)
select distinct 
        initcap(trim(regexp_replace(r.driver_name,'\s+',' ','g' ))) as regexp
from rides r;
-- checking the inserted data in the drivers table.
select * from drivers d ;

-- Inserting cleaned data ( by using initcap/trim/regexp_replace for data consitency ) into passengers table.

insert into passengers  (passenger_name)
select distinct 
        initcap(trim(regexp_replace(r.passenger_name,'\s+',' ','g' ))) as regexp
from rides r;

-- checking the inserted data in the passengers table.

select * from passengers ;

-- Inserting cleaned data ( by using initcap/trim/regexp_replace for data consitency ) into locations table.
insert into locations(city_name)
select distinct 
        initcap(trim(regexp_replace(r.pickup_city,'\s+',' ','g' ))) 
from rides r
union -- Union used for cases where count ( distinct ( r.pickup_city ) ) > count ( distinct ( r.dropoff_city ))
select distinct 
        initcap(trim(regexp_replace(r.dropoff_city,'\s+',' ','g' ))) 
from rides r;

-- checking the inserted data in the passengers table.

select * from locations;




-- Inserting data into payment_methods table.
insert into payment_methods ( payment_method_name)
select distinct trim(payment_method)
from rides 
where payment_method is not null;

-- checking the inserted data in the payments methods table.

select * from payment_methods pm ;

-- query to check foreign keys and data correlations to data in ride table before inserting final data into trips table.
select
	(select  driver_id
		from drivers d
	 where d.driver_name = initcap(trim(regexp_replace(r.driver_name, '\s+', ' ','g' ))) ),
	 (select  passenger_id
		from passengers p 
	 where p.passenger_name = initcap(trim(regexp_replace(r.passenger_name, '\s+', ' ','g' ))) ),
	 (select  location_id
		from locations l  
	 where l.city_name = initcap(trim(regexp_replace(r.pickup_city, '\s+', ' ','g' ))) ),
	 (select  location_id
		from locations l  
	 where l.city_name = initcap(trim(regexp_replace(r.dropoff_city, '\s+', ' ','g' )))),
	 r.fare_amount,
	 r.ride_distance_km,
	 r.ride_status,
	 r.requested_at, 
	 r.completed_at,
	 r.rating,
	 (select  payment_method_id
		from payment_methods pm   
	 where pm.payment_method_name = trim(r.payment_method)),
	 *
from rides r;

-- inserting foreign keys and relevant data into trips, ensuring normalization and clean data.

insert into trips (
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
	payment_method_id)
select
	(select  driver_id
		from drivers d
	 where d.driver_name = initcap(trim(regexp_replace(r.driver_name, '\s+', ' ','g' ))) ),
	 (select  passenger_id
		from passengers p 
	 where p.passenger_name = initcap(trim(regexp_replace(r.passenger_name, '\s+', ' ','g' ))) ),
	 (select  location_id
		from locations l  
	 where l.city_name = initcap(trim(regexp_replace(r.pickup_city, '\s+', ' ' ,'g'))) ),
	 (select  location_id
		from locations l  
	 where l.city_name = initcap(trim(regexp_replace(r.dropoff_city, '\s+', ' ','g' )))),
	 r.fare_amount,
	 r.ride_distance_km,
	 r.ride_status,
	 r.requested_at, 
	 r.completed_at,
	 r.rating,
	 (select  payment_method_id
		from payment_methods pm   
	 where pm.payment_method_name = trim(r.payment_method))
from rides r;

-- checking the inserted data in the trips table.

select * from trips;

select count(*) from trips;
select count(*) from rides;

-- Verifying end to end
select t.trip_id, d.driver_name, p.passenger_name,
       pl.city_name AS pickup, dl.city_name AS dropoff,
       t.fare_amount, t.status, pm.payment_method_name
from trips t
join drivers d ON t.driver_id = d.driver_id
join passengers p ON t.passenger_id = p.passenger_id
join  locations pl ON t.pickup_location_id = pl.location_id
join locations dl ON t.dropoff_location_id = dl.location_id
left  join payment_methods pm ON t.payment_method_id = pm.payment_method_id
limit 10;


