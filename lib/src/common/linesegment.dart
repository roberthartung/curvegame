part of curvegame.common;

class LineSegment extends PathSegment {
  num distance = 0;
  
  LineSegment(Vector beginDirection, math.Point begin, int width, {this.distance}) : super(beginDirection, begin, width);
  
  LineSegment.fromObject(Map data) : super.fromObject(data) {
    distance = data['distance'];
  }
  
  math.Point getEndPoint() {
    return new math.Point(begin.x + beginDirection.x * distance, begin.y + beginDirection.y * distance);
  }
  
  Map toObject() {
    Map map = super.toObject();
    map['distance'] = distance;
    return map;
  }
  
  void draw(ctx) {
    ctx.moveTo(begin.x, begin.y);
    math.Point endPoint = getEndPoint();
    ctx.lineTo(endPoint.x, endPoint.y);
  }
  
  bool containsPoint(math.Point point) {
    math.Point end = getEndPoint();
    
    num minX = math.min(begin.x, end.x);
    num maxX = math.max(begin.x, end.x);
    num minY = math.min(begin.y, end.y);
    num maxY = math.max(begin.y, end.y);
    
    if(minX <= point.x && maxX >= point.x && minY <= point.y && maxY >= point.y) {
      double c1 = (point.x - begin.x) / (end.x - begin.x);
      double c2 = (point.y - begin.y) / (end.y - begin.y);
      
      if((c1-c2).abs() < 0.1) {
        return true;
      }
    }
    
    return false;
  }
}