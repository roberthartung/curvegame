part of curvegame.common;

class ArcSegment extends PathSegment {
  num angle = 0;
  
  num radius;
  
  ArcDirection direction;
  
  Vector directionVector;
  
  math.Point arcMiddle;
  
  Vector arcVector;
  
  num startAngle;
  
  ArcSegment(Vector beginDirection, math.Point begin, int width, this.direction, this.radius, this.angle) : super(beginDirection, begin, width) {
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
  
  bool containsPoint(math.Point point) {
    double distance = point.distanceTo(arcMiddle);
    if(distance < (radius - width/2) || distance > (radius+width/2)) {
      return false;
    }
    
    Vector pointDirection = new Vector(point.x - arcMiddle.x, point.y - arcMiddle.y);
    double angle = pointDirection.angle();
    
    double endAngle = getEndAngle();
    
    if(startAngle <= angle && endAngle >= angle) {
      return true;
    }
    
    if(startAngle <= angle && (endAngle+360) >= angle) {
      return true;
    }
    
    if(startAngle-360 <= angle && (endAngle) >= angle) {
      return true;
    }
    
    return false;
  }
}