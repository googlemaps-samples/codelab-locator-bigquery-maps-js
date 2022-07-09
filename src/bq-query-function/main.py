"""Generates a CSV from a Big Query Table."""
from flask import escape
from flask import jsonify, make_response,request
import functions_framework
import google.cloud
import google.cloud.bigquery
import json

@functions_framework.http
def gmp_bq_query(request):
  """Generates CSV from Big Query Table and places it in Cloud Storage bucket."""
  client = google.cloud.bigquery.Client()

  # Set the necessary values for Big Query Assets
  project = "PROJECT_ID"
  dataset_id = "DATASET_ID"
  table_id = "TABLE_ID"

  # Create params for ingestion
  # Month abbreviation, day and year
  
  dataset_ref = google.cloud.bigquery.DatasetReference(project, dataset_id)
  
  #table_ref = dataset_ref.table(table_id)
  args = request.args
  query=""
  coordinates = args.get('coordinates')
  center_lnt=args.get('center-lnt')
  center_lat=args.get('center-lat')
  radius=args.get('radius')
  if center_lnt is None:
    query = """
    WITH polygon AS (SELECT ST_GEOGFROMTEXT('Polygon(("""+coordinates+ """))') AS p)
SELECT pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude, pickup_datetime
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`, polygon
WHERE ST_CONTAINS(polygon.p,ST_GEOGPOINT(pickup_longitude,pickup_latitude))
AND (pickup_datetime BETWEEN CAST("2016-01-01 00:00:01" AS DATETIME) AND CAST("2016-02-28 23:59:59" AS DATETIME))
LIMIT 10000
  """
  elif coordinates is None:
     query = """
    WITH mypoint AS (SELECT ST_GEOGPOINT("""+center_lnt+","+center_lat+ """) AS p)
SELECT pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude, pickup_datetime
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`, mypoint
WHERE ST_DISTANCE(mypoint.p,ST_GEOGPOINT(pickup_longitude,pickup_latitude))<"""+radius +""" AND (pickup_datetime BETWEEN CAST("2016-01-01 00:00:01" AS DATETIME) AND CAST("2016-02-28 23:59:59" AS DATETIME))
LIMIT 10000
  """
  
  query_job = client.query(query)  # Make an API request.

  result=[]
  for row in query_job:
        # Row values can be accessed by field name or index
       result.append({"longitude": row["pickup_longitude"], "latitude": row["pickup_latitude"]})
      
        
    # [END bigquery_query]
  
           
  response=make_response(jsonify(result), 200)
  response.headers['Access-Control-Allow-Origin']='*'
  #response.headers['Access-Control-Allow-Methods']='GET'
  response.headers['Access-Control-Allow-Headers']='Origin, X-Requested-With, Content-Type, Accept'
  response.headers['Content-Type']='application/json'
  #response.headers['Access-Control-Max-Age']='3600'
     
  return response
