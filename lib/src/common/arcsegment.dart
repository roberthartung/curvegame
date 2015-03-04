part of curvegame.common;

class ArcSegment extends PathSegment {
  num angle = 0;
  
  num radius;
  
  ArcDirection direction;
  
  Vector directionVector;
  
  math.Point arcMiddle;
  
  Vector arcVector;
  
  num startAngle;
  
  ArcSegment(Vector beginDirection, math.Point begin, int width, num startDistance, this.direction, this.radius, this.angle) : super(beginDirection, begin, width, startDistance) {
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
    arcMiddle = new math.Point(begin.x + directionVector.x * radius,  begin.y + directionVector.y * radius);
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
  
  math.Point getEndPoint() {
    Vector endVector = arcVector.rotate(direction == ArcDirection.LEFT ? (360-angle) : angle);
    return new math.Point(arcMiddle.x + endVector.x * radius, arcMiddle.y + endVector.y * radius);
  }
  
  Vector getEndDirection() {
    return beginDirection.rotate(direction == ArcDirection.LEFT ? (360-angle) : angle);
  }
  
  void draw(ctx) {
    ctx.arc(arcMiddle.x, arcMiddle.y, radius, startAngle/180*math.PI, getEndAngle()/180*math.PI, direction == ArcDirection.LEFT ? true : false);
  }
  
  Map toObject() {
    Map map = super.toObject();
    map['direction'] = direction == ArcDirection.LEFT ? 'LEFT' : 'RIGHT';
    map['radius'] = radius;
    map['angle'] = angle;
    return map;
  }
  
  num getSegmentDistance() => (2 * math.PI * radius * angle / 360);
  
  bool containsPoint(math.Point point) {
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