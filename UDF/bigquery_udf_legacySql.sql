SELECT latitude,longitude FROM pointInPolygon(
  SELECT pickup_longitude, pickup_latitude, pickup_datetime
  FROM [bigquery-public-data:new_york.tlc_yellow_trips_2016]
  WHERE pickup_datetime BETWEEN TIMESTAMP("2016-01-01 00:00:01") AND TIMESTAMP("2016-01-29 23:59:59")
)
LIMIT 100
