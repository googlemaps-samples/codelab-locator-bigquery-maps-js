//JavaScript UDF for point in polygon calculation using Legacy SQL approach
bigquery.defineFunction("pointInPolygon",
  ["pickup_latitude", "pickup_longitude", "pickup_datetime"],
  [
    {name: "latitude", type: "float"},
    {name: "longitude", type: "float"},
    {name:"pickup_datetime", type:"string"}
  ],
  inPoly
);

function pointInPoly(polygon, point){
  var vertx = [];
  var verty = [];
  var nvert = 0;
  var testx = point[0];
  var testy = point[1];
  for(coord in polygon){
    vertx[nvert] = polygon[coord][0];
    verty[nvert] = polygon[coord][1];
    nvert ++;
  }
  var i, j, c = 0;
  for (i = 0, j = nvert-1; i < nvert; j = i++) {
    if ( ((verty[i]>testy) != (verty[j]>testy)) &&(testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
    {c = !c;}
  }
  return c;
}

function inPoly(row, emit){
  var poly=[
    [-73.98925602436066,40.743249676056955],
    [-73.98836016654968,40.74280666503313],
    [-73.98915946483612,40.741676770346295],
    [-73.98967981338501,40.74191656974406]
  ];
  var pt = [row.pickup_longitude,row.pickup_latitude];
  var result = pointInPoly(poly, pt);
  if(result) {
    emit({latitude: pt[1], longitude: pt[0]});
  }
}
