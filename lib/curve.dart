part of curvegame;

class Vector<T extends num> {
  T x;
  
  T y;
  
  Vector(this.x, this.y) {
    double l = length();
    // Type casting not needed. But added to remove the warning.
    x = (x/l) as T;
    y  = (y/l) as T;
  }
  
  double length() {
    return sqrt(x*x+y*y);
  }
  
  /**
   * Returns a new vector rotates by [degress] degress
   */
  
  Vector rotate(num degrees) {
    double radians = degrees * (PI / 180);
    return new Vector(x * cos(radians) - y * sin(radians), x * sin(radians) + y * cos(radians));
  }
  
  /**
   * Returns a angle (0..360 degress) which is the angle between the x axis in clock wise rotation 
   */
  
  num angle() {
    num angle = (atan2(y,x) - atan2(0,1)) * 180 / PI;
    if(y < 0) {
      angle += 360;
    }
    return angle;
  }
  
  String toString() {
    return "Vector($x,$y)";
  }
}

abstract class PathSegment {
  /**
   * Starting direction
   */
  
  Vector beginDirection;
  
  /**
   * Start point
   */
  
  Point begin;
  
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
    begin = new Point(data['begin']['x'], data['begin']['y']);
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
  
  bool containsPoint(Point point);
  
  Point getEndPoint();
}

class ArcSegment extends PathSegment {
  num angle = 0;
  
  num radius;
  
  ArcDirection direction;
  
  Vector directionVector;
  
  Point arcMiddle;
  
  Vector arcVector;
  
  num startAngle;
  
  ArcSegment(Vector beginDirection, Point begin, int width, num startDistance, this.direction, this.radius, this.angle) : super(beginDirection, begin, width, startDistance) {
    _init();
  }
  
  ArcSegment.fromObject(Map data) : super.fromObject(data) {
    direction = data['direction'] == 'LEFT' ? ArcDirection.LEFT : ArcDirection.RIGHT;
    angle = data['angle'];
    radius = data['radius'];
    _init();
  }
  
  void _init() {
    directionVector = beginDirection.rotate(direction == ArcDirection.LEFT ? -90 : 90);
    arcMiddle = new Point(begin.x + directionVector.x * radius,  begin.y + directionVector.y * radius);
    arcVector = directionVector.rotate(180);
    startAngle = arcVector.angle();
  }
  
  num getEndAngle() {
    num endAngle;
    if(direction == ArcDirection.LEFT) {
      endAngle = (startAngle+(360-angle) % 360);
    } else {
      endAngle = ((startAngle + angle) % 360);
    }
    return endAngle;
  }
  
  Point getEndPoint() {
    Vector endVector = arcVector.rotate(direction == ArcDirection.LEFT ? (360-angle) : angle);
    return new Point(arcMiddle.x + endVector.x * radius, arcMiddle.y + endVector.y * radius);
  }
  
  Vector getEndDirection() {
    return beginDirection.rotate(direction == ArcDirection.LEFT ? (360-angle) : angle);
  }
  
  void draw(ctx) {
    ctx.arc(arcMiddle.x, arcMiddle.y, radius, startAngle/180*PI, getEndAngle()/180*PI, direction == ArcDirection.LEFT ? true : false);
  }
  
  Map toObject() {
    Map map = super.toObject();
    map['direction'] = direction == ArcDirection.LEFT ? 'LEFT' : 'RIGHT';
    map['radius'] = radius;
    map['angle'] = angle;
    return map;
  }
  
  num getSegmentDistance() => (2 * PI * radius * angle / 360);
  
  bool containsPoint(Point point) {
    double distance = point.distanceTo(arcMiddle);
    if(distance < (radius - width/2) || distance > (radius+width/2)) {
      return false;
    }
    
    Vector pointDirection = new Vector(point.x - arcMiddle.x, point.y - arcMiddle.y);
    double angle = pointDirection.angle();
    num _startAngle = (direction == ArcDirection.LEFT) ? getEndAngle() : startAngle;
    num _endAngle = (direction == ArcDirection.LEFT) ? startAngle : getEndAngle();
    
    if(_startAngle > _endAngle) {
      _endAngle += 360;
    }
    
    if(_startAngle <= angle && _endAngle >= angle) {
      //print('1: $_startAngle $angle $_endAngle');
      return true;
    }
    
    angle += 360;
    
    if(_startAngle <= angle && _endAngle >= angle) {
      //print('2: $_startAngle $angle $_endAngle');
      return true;
    }
    
    return false;
  }
  
  String toString() => "[ArcSegment,$radius,$begin,$startDistance,$angle]";
}

class LineSegment extends PathSegment {
  num length;
  
  LineSegment(Vector beginDirection, Point begin, int width, num startDistance, {this.length: 0}) : super(beginDirection, begin, width, startDistance);
  
  LineSegment.fromObject(Map data) : super.fromObject(data) {
    length = data['length'];
  }
  
  Point getEndPoint() {
    return new Point(begin.x + beginDirection.x * length, begin.y + beginDirection.y * length);
  }
  
  Map toObject() {
    Map map = super.toObject();
    map['length'] = length;
    return map;
  }
  
  void draw(ctx) {
    ctx.moveTo(begin.x, begin.y);
    Point endPoint = getEndPoint();
    ctx.lineTo(endPoint.x, endPoint.y);
  }
  
  bool containsPoint(Point point) {
    Point end = getEndPoint();
    
    num minX = min(begin.x, end.x);
    num maxX = max(begin.x, end.x);
    num minY = min(begin.y, end.y);
    num maxY = max(begin.y, end.y);
    
    if(minX <= point.x && maxX >= point.x && minY <= point.y && maxY >= point.y) {
      num distance = ((end.y-begin.y)*point.x-(end.x-begin.y)*point.y+end.x*begin.y-end.y*begin.x).abs() / sqrt(pow(end.y - begin.y, 2) + pow(end.x - begin.y, 2));
      if(distance <= width/2) {
        return true;
      }
    }
    return false;
  }
  
  num getSegmentDistance() => length;
}