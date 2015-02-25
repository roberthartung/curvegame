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
   * Default constructor (server)
   */
  
  PathSegment(this.beginDirection, this.begin, this.width);
  
  /**
   * Object constructor (client)
   */
  
  PathSegment.fromObject(Map data) {
    beginDirection = new Vector(data['beginDirection']['x'], data['beginDirection']['y']);
    begin = new math.Point(data['begin']['x'], data['begin']['y']);
    width = data['width'];
  }
  
  Map toObject() {
    return {'width': width, 'beginDirection': {'x': beginDirection.x, 'y': beginDirection.y}, 'begin': {'x': begin.x, 'y': begin.y}};
  }
  
  void draw(ctx);
  
  math.Point getEndPoint();
}