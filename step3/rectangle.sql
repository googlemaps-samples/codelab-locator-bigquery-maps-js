SELECT 
ROUND(AVG(tip_amount),2) as avg_tip, 
ROUND(AVG(fare_amount),2) as avg_fare, 
ROUND(AVG(trip_distance),2) as avg_distance, 
ROUND(AVG(tip_proportion),2) as avg_tip_pc, 
ROUND(AVG(fare_per_mile),2) as avg_fare_mile FROM

(SELECT 

pickup_latitude, pickup_longitude, tip_amount, fare_amount, trip_distance, (tip_amount / fare_amount)*100.0 as tip_proportion, fare_amount / trip_distance as fare_per_mile

FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2015`

WHERE trip_distance > 0.01 AND fare_amount <100 AND payment_type = "1" AND fare_amount > 0
)

--Manhattan
WHERE pickup_latitude < 40.7679 AND pickup_latitude > 40.7000 AND pickup_longitude < -73.97 and pickup_longitude > -74.01

--JFK
--WHERE pickup_latitude < 40.654626 AND pickup_latitude > 40.639547 AND pickup_longitude < -73.771497 and pickup_longitude > -73.793755
