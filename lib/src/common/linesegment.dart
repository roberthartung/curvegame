part of curvegame.common;

class LineSegment extends PathSegment {
  num length;
  
  LineSegment(Vector beginDirection, math.Point begin, int width, num startDistance, {this.length: 0}) : super(beginDirection, begin, width, startDistance);
  
  LineSegment.fromObject(Map data) : super.fromObject(data) {
    length = data['length'];
  }
  
  math.Point getEndPoint() {
    return new math.Point(begin.x + beginDirection.x * length, begin.y + beginDirection.y * length);
  }
  
  Map toObject() {
    Map map = super.toObject();
    map['length'] = length;
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
      num distance = ((end.y-begin.y)*point.x-(end.x-begin.y)*point.y+end.x*begin.y-end.y*begin.x).abs() / math.sqrt(math.pow(end.y - begin.y, 2) + math.pow(end.x - begin.y, 2));
      if(distance <= width/2) {
        return true;
      }
    }
    return false;
  }
  
  num getSegmentDistance() => length;
}