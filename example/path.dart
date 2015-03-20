import 'dart:html';
import 'dart:math' as math;
/*
import 'package:curvegame/common.dart' as common;

enum Side {LEFT, RIGHT}

void drawPoint(Point p, String color) {
  ctx.save();
  ctx.beginPath();
  ctx.arc(p.x, p.y, 3, 0, 2*math.PI);
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.stroke();
  ctx.fill();
  ctx.restore();
}

Point position;
common.Vector direction;
common.ArcDirection side = common.ArcDirection.RIGHT;
int radius = 30;
int angle = 80;
int width = 4;
CanvasElement canvas;
CanvasRenderingContext2D ctx;

common.ArcSegment arcSegment;

void createArc() {
  arcSegment = new common.ArcSegment(direction, position, width, 0, side, radius, angle);
}

void main() {
  position = new Point(100,100);
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
  double radians = 22.5/180*math.PI;
  direction = new common.Vector(math.cos(radians), math.sin(radians));
  createArc();
    
  querySelector('#angle').onChange.listen((ev) {
    angle = int.parse(ev.target.value);
    createArc();
  });
  
  querySelector('#radius').onChange.listen((ev) {
    radius = int.parse(ev.target.value);
    createArc();
  });
  
  querySelector('#directionAngle').onChange.listen((ev) {
    double radians = double.parse(ev.target.value)/180*math.PI;
    direction = new common.Vector(math.cos(radians), math.sin(radians));
    createArc();
  });
  
  querySelector('#side').onChange.listen((ev) {
    switch(ev.target.value) {
      case 'left' :
        side = common.ArcDirection.LEFT;
        break;
      case 'right' :
        side = common.ArcDirection.RIGHT;
        break;
    }
    createArc();
  });
  
  window.requestAnimationFrame(draw);
}

void draw(num frame) {
  /*
  // Initial direction vector
  common.Vector directionVector = direction.rotate(side == Side.LEFT ? -90 : 90);
  // Middle point
  Point arcMiddle = new Point(position.x + directionVector.x * radius,  position.y + directionVector.y * radius);
  common.Vector arcVector = directionVector.rotate(180);
  num startAngle = arcVector.angle();
  num endAngle;
  if(side == Side.LEFT) {
   endAngle = (startAngle+(360-angle) % 360);
  } else {
   endAngle = ((startAngle + angle) % 360);
  }
  
  common.Vector endVector = arcVector.rotate(side == Side.LEFT ? (360-angle) : angle);
  Point endPoint = new Point(arcMiddle.x + endVector.x * radius, arcMiddle.y + endVector.y * radius);
  common.Vector endDirection = direction.rotate(side == Side.LEFT ? (360-angle) : angle);
  */
  
  Point endPoint = arcSegment.getEndPoint();
  common.Vector endDirection = arcSegment.getEndDirection();
  
  // Draw
  ctx.clearRect(0, 0, canvas.width,  canvas.height);
  ctx.save();
  ctx.scale(2, 2);
  ctx.lineWidth = 2;
  
  // Draw position
  drawPoint(position, 'red');
  
  // Draw direction
  ctx.save();
  ctx.strokeStyle = 'white';
  ctx.beginPath();
  ctx.moveTo(position.x, position.y);
  ctx.lineTo(position.x + direction.x * arcSegment.radius,  position.y + direction.y * arcSegment.radius);
  ctx.stroke();
  ctx.restore();
  
  // Draw middle point
  drawPoint(arcSegment.arcMiddle, 'yellow');
  
  ctx.save();
  ctx.strokeStyle = 'yellow';
  ctx.beginPath();
  ctx.moveTo(arcSegment.arcMiddle.x, arcSegment.arcMiddle.y);
  ctx.lineTo(endPoint.x, endPoint.y);
  ctx.stroke();
  ctx.restore();
  
  drawPoint(endPoint, 'cyan');
  
  ctx.save();
  ctx.strokeStyle = 'red';
  ctx.fillStyle = 'red';
  ctx.lineWidth = 5;
  ctx.beginPath();
  arcSegment.draw(ctx);
  //ctx.arc(arcMiddle.x, arcMiddle.y, radius, startAngle/180*math.PI, endAngle/180*math.PI, side == Side.LEFT ? true : false);
  ctx.stroke();
  ctx.restore();
  
  ctx.save();
  ctx.strokeStyle = 'cyan';
  ctx.beginPath();
  ctx.moveTo(endPoint.x, endPoint.y);
  ctx.lineTo(endPoint.x + endDirection.x * arcSegment.radius,  endPoint.y + endDirection.y * arcSegment.radius);
  ctx.stroke();
  ctx.restore();
  
  // UNIT TESTING
  /*
  print(new common.Vector(1,0).angle());    // 0
  print(new common.Vector(1,1).angle());   // 45
  print(new common.Vector(0,1).angle());   // 90
  print(new common.Vector(-1,1).angle());  // 135
  print(new common.Vector(-1,0).angle());   // 180
  print(new common.Vector(-1,-1).angle());   // 225
  print(new common.Vector(0,-1).angle());    // 270
  print(new common.Vector(1,-1).angle());    // 315
  */
  
  // DEPRECATED
  //Point endPoint = new Point(arcMiddle.x, arcMiddle.y);
  /*
  ctx.strokeStyle = 'green';
  ctx.beginPath();
  // ctx.moveTo(position.x, position.y);
  ctx.arc(arcMiddle.x, arcMiddle.y, radius, -45/180 * math.PI, 90/180 * math.PI);
  //ctx.arcTo(position.x + direction.x * radius,  position.y + direction.x * radius, endPoint.x, endPoint.y, radius);
  ctx.stroke();
  */
  
  ctx.restore();
  
  window.requestAnimationFrame(draw);
}
*/