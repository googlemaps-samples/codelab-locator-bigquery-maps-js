CREATE TEMPORARY FUNCTION pointInPolygon(latitude FLOAT64, longitude FLOAT64)
RETURNS BOOL LANGUAGE js AS """
  var polygon=[[-73.98925602436066,40.743249676056955],[-73.98836016654968,40.74280666503313],[-73.98915946483612,40.741676770346295],[-73.98967981338501,40.74191656974406]];

  var vertx = [];
  var verty = [];
  var nvert = 0;
  var testx = longitude;
  var testy = latitude;

  for(coord in polygon){
    vertx[nvert] = polygon[coord][0];
    verty[nvert] = polygon[coord][1];
    nvert ++;
  }
  var i, j, c = 0;
  for (i = 0, j = nvert-1; i < nvert; j = i++) {
    if ( ((verty[i]>testy) != (verty[j]>testy)) &&(testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) ){
      c = !c;
    }
  }
  return c;
""";

SELECT pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude, pickup_datetime
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2016`
WHERE pointInPolygon(pickup_latitude, pickup_longitude) = TRUE
AND (pickup_datetime BETWEEN TIMESTAMP("2016-01-01 00:00:01") AND TIMESTAMP("2016-02-28 23:59:59"))
LIMIT 100
