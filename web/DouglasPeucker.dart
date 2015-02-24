import 'dart:math';

abstract class DouglasPeucker {
  static List<Point> douglasPeucker(List<Point> points, num epsilon) {
    num dmax = 0;
    int index = 0;
    int end = points.length - 1;
    
    if(epsilon <= 0 || end < 2) {
      return points;
    }
    
    Point firstPoint = points.first;
    Point lastPoint = points.last;
    
    for(int i=1; i<end; i++) {
      double d = distanceFromPointToLine(firstPoint, lastPoint, points.elementAt(i));
      if(d > dmax) {
        index = i;
        dmax = d;
      }
    }
    
    //print('dmax: $dmax');
    
    List<Point> result = new List<Point>();
    // Path2D result = new Path2D();
    if(dmax >= epsilon) {
      result.addAll( douglasPeucker(points.sublist(0, index-1), epsilon) );
      result.addAll( douglasPeucker(points.sublist(index-1, end), epsilon) );
    } else {
      result.add(firstPoint);
      result.add(lastPoint);
    }
    
    return result;
  }
  
  static num distanceFromPointToLine(Point p1, Point p2, Point p0) {
    num x0 = p0.x;
    num y0 = p0.y;
    num x1 = p1.x;
    num y1 = p1.y;
    num x2 = p2.x;
    num y2 = p2.y;
    return ((y2-y1)*x0 - (x2-x1)*y0 + x2*y1 - y2*x1) / sqrt(((y2-y1)*(y2-y1) + (x2-x1)*(x2-x1))).abs();
  }
}