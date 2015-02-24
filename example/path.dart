import 'dart:html';
import 'dart:math' as math;

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
Side side;
int radius;
int angle;
common.Vector direction;
CanvasElement canvas;
CanvasRenderingContext2D ctx;

void main() {
  side = Side.RIGHT;
  radius = 30;
  angle = 90;
  position = new Point(100,100);
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
  direction = new common.Vector(2,1);
    
  querySelector('#angle').onChange.listen((ev) {
    angle = int.parse(ev.target.value);
  });
  
  querySelector('#radius').onChange.listen((ev) {
    radius = int.parse(ev.target.value);
  });
  
  querySelector('#side').onChange.listen((ev) {
    switch(ev.target.value) {
      case 'left' :
        side = Side.LEFT;
        break;
      case 'right' :
        side = Side.RIGHT;
        break;
    }
  });
  
  window.requestAnimationFrame(draw);
}

void draw(num frame) {
  common.Vector directionVector = direction.rotate(side == Side.LEFT ? -90 : 90);
  
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
  ctx.lineTo(position.x + direction.x * radius,  position.y + direction.y * radius);
  ctx.stroke();
  ctx.restore();
  
  // Middle point
  Point arcMiddle = new Point(position.x + directionVector.x * radius,  position.y + directionVector.y * radius);
  // Draw middle point
  drawPoint(arcMiddle, 'yellow');
  
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
  
  ctx.save();
  ctx.strokeStyle = 'yellow';
  ctx.beginPath();
  ctx.moveTo(arcMiddle.x, arcMiddle.y);
  ctx.lineTo(endPoint.x, endPoint.y);
  ctx.stroke();
  ctx.restore();
  
  drawPoint(endPoint, 'cyan');
  
  ctx.save();
  ctx.strokeStyle = 'red';
  ctx.fillStyle = 'red';
  ctx.lineWidth = 5;
  ctx.beginPath();
  ctx.arc(arcMiddle.x, arcMiddle.y, radius, startAngle/180*math.PI, endAngle/180*math.PI, side == Side.LEFT ? true : false);
  ctx.stroke();
  ctx.restore();
  
  common.Vector endDirection = direction.rotate(side == Side.LEFT ? (360-angle) : angle);
  
  ctx.save();
  ctx.strokeStyle = 'cyan';
  ctx.beginPath();
  ctx.moveTo(endPoint.x, endPoint.y);
  ctx.lineTo(endPoint.x + endDirection.x * radius,  endPoint.y + endDirection.y * radius);
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