// Point in polygon code.
// Based in part on the C implementation at https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
// Uses a ray-tracing algorithm, see https://en.wikipedia.org/wiki/Point_in_polygon
var inLineJs = 'function pointInPoly(polygon, point){' +
  'var vertx = [];' +
  'var verty = [];' +
  'var nvert = 0;' +
  'var testx = point[0];' +
  'var testy = point[1];' +
  'for(coord in polygon){' +
    'vertx[nvert] = polygon[coord][0];' +
    'verty[nvert] = polygon[coord][1];' +
    'nvert ++;' +
  '}' +
  'var i, j, c = 0;' +
  'for (i = 0, j = nvert-1; i < nvert; j = i++) {' +
    'if ( ((verty[i]>testy) != (verty[j]>testy)) &&(testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) ){' +
      'c = !c;' +
    '}' +
  '}' +
  'return c;' +
'}';
