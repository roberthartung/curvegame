part of curvegame.common;

abstract class PathSegment {
  /**
   * Starting direction
   */
  
  Vector beginDirection;
  
  /**
   * Start point
   */
  
  math.Point begin;
  
  /**
   * Line width
   */
  
  int width;
  
  /**
   * Distance this segment starts at
   */
  
  num startDistance;
  
  /**
   * Default constructor (server)
   */
  
  PathSegment(this.beginDirection, this.begin, this.width, this.startDistance);
  
  /**
   * Object constructor (client)
   */
  
  PathSegment.fromObject(Map data) {
    beginDirection = new Vector(data['beginDirection']['x'], data['beginDirection']['y']);
    begin = new math.Point(data['begin']['x'], data['begin']['y']);
    width = data['width'];
    startDistance = data['startDistance'];
  }
  
  Map toObject() {
    return {'width': width,
      'startDistance': startDistance,
      'beginDirection': {'x': beginDirection.x, 'y': beginDirection.y},
      'begin': {'x': begin.x, 'y': begin.y}};
  }
  
  num getSegmentDistance();
  
  num getTotalDistance() => startDistance + getSegmentDistance();
  
  void draw(ctx);
  
  bool containsPoint(math.Point point);
  
  math.Point getEndPoint();
}