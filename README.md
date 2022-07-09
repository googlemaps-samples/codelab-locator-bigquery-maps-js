# Google Maps API and BigQuery Codelab

## Synopsis

This is not an official Google product.

This project demonstrates how to perform simple geospatial queries against a Google BigQuery table that contains latitude, longitude data in columns. It also shows how to use the Google Maps Platform's Maps JavaScript API to present a visual interface for the queries and the query results. The code accompanies a codelab which can be found [on the Codelabs page at the Google Developers site](https://codelabs.developers.google.com/codelabs/bigquery-maps-api). The files are arranged in sequential order to demonstrate progress through the codelab, but if you want you can jump [straight in to the finished example](step7/map.html "Finished example").

## Motivation

The project and accompanying Codelab aim to illustrate some ways to work with and visualize geospatial and location data in BigQuery tables without needing specialized libraries, ETL workflows or spatial data formats.

## Installation

The repo consists of static HTML files that can be run from a local computer or any web server.

To get it working, you'll need to sign up for BigQuery and the Google Maps API. See the codelab for more detailed instructions, but the basic steps to get this running are:
- Sign up for a [Google Cloud Platform account](https://cloud.google.com/) and create or use an existing project.
- Enable the [BigQuery API](https://cloud.google.com/bigquery/bigquery-api-quickstart "BigQuery API quick start instructions") and the [Google Maps Javascript API](https://developers.google.com/maps/documentation/javascript/ "Google Maps API documentation") in the Developer Console.
- Enable the [Maps JavaScript API](https://console.cloud.google.com/marketplace/details/google/maps-backend.googleapis.com)) for your project.
- Create a new API Key for use with the Google Maps Platform, with a Browser restriction.
- Choose a BigQuery dataset to query. There are several public datasets with latitude/longitude data.
- modify the code to replace the placeholders for API keys, and BigQuery dataset and table name parameters with your own specific values for these.
- Install the default Cloud HTTP function, wrap the BigQuery API calls through Python Client APIs.
Go to GCP cloud shell, run the following commands:
```shellcript
PROJECT_ID=YOUR_PROJECT_ID
cd $HOME
git clone https://github.com/rick-c-goog/bigquery-maps-api.git
cd $HOME/gmp-dds-bq-example
gcloud config set project $PROJECT_ID  
./start.sh
```
If something goes wrong, run ./start/sh again.

Cloud Function Validation steps:
 Go to Cloud Function console screen, make sure cloud function, gmp-bq-function created successfully( green check on left side). 
- Make sure Chrome WebServer installed properly
- Download step1 to step8 folder to local machine with Chrome browser available
- In the stepN folder, edit the map.html file with following lines:
  1. http_function_url="https://us-east1-PROJECT_ID.cloudfunctions.net/gmp-bq-function" , replace with your own PROJECT_ID
  2.  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&callback=initMap" async defer></script> , replace YOUR_API_KEY with your own value
- Set Chrome WebServer directory to stepN folder downloaded with the updated configuration, step7 contains the final step. 
- Navigate through Google Map function and BigQuery connection functions.   


## API Reference

For a general overview of Google BigQuery see [What Is BigQuery?](https://cloud.google.com/bigquery/what-is-bigquery "What is BigQuery?")

You may find it helpful to refer to the [Google Maps Platform documentation](https://developers.google.com/maps/documentation "Google Maps API documentation"), the Google BigQuery reference, and the [BigQuery Python Client API](https://github.com/googleapis/python-bigquery "BigQuery Python Client API") reference.

## License

This project is licensed under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0.txt "Apache 2.0 license").
