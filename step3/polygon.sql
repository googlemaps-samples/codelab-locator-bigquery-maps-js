WITH polygon AS (SELECT ST_GEOGFROMTEXT('Polygon((-73.98925602436066 40.743249676056955,-73.98836016654968 40.74280666503313,-73.98915946483612 40.741676770346295,-73.98967981338501 40.74191656974406,-73.98925602436066 40.743249676056955))') AS p)
SELECT pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude, pickup_datetime
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`, polygon
WHERE ST_CONTAINS(polygon.p,ST_GEOGPOINT(pickup_longitude,pickup_latitude))
AND (pickup_datetime BETWEEN CAST("2016-01-01 00:00:01" AS DATETIME) AND CAST("2016-02-28 23:59:59" AS DATETIME))
LIMIT 1000