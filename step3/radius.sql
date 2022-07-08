'''
with mypoint as (SELECT st_GEOMPOINT(-73.99585,40.73943) AS p)
SELECT pickup_latitude, pickup_longitude, 
    ST_DISTANCE(ST_GEOMPOINT(pickup_longitude,pickup_latitude),p) AS distance FROM `project.dataset.tableName` 
    HAVING distance < 0.1 
'''
with mypoint as (SELECT st_GEOGPOINT(-73.985731,40.748459) AS p)
SELECT 

ROUND(AVG(tip_amount),2) as avg_tip,
ROUND(AVG(fare_amount),2) as avg_fare,
ROUND(AVG(trip_distance),2) as avg_distance,
ROUND(AVG(tip_proportion), 2) as avg_tip_pc,
ROUND(AVG(fare_per_mile),2) as avg_fare_mile

FROM
(SELECT pickup_latitude, pickup_longitude, tip_amount, fare_amount, trip_distance, tip_amount/fare_amount*100 as tip_proportion, fare_amount / trip_distance as fare_per_mile, ST_DISTANCE(ST_GEOGPOINT(pickup_longitude,pickup_latitude),p) as distanceEMP
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`, mypoint
WHERE 
   ST_DISTANCE(ST_GEOGPOINT(pickup_longitude,pickup_latitude),p) < 0.3
  AND fare_amount > 0 and trip_distance > 0
  )
WHERE fare_amount < 100