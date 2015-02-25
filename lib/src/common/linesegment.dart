part of curvegame.common;

class LineSegment extends PathSegment {
  num distance = 0;
  
  LineSegment(Vector beginDirection, math.Point begin, int width) : super(beginDirection, begin, width);
  
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
}