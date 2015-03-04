import 'dart:math';
import 'dart:html';
import 'package:curvegame/common.dart';

CanvasRenderingContext2D ctx;
CanvasElement canvas;
ArcSegment arc;
LineSegment line;
Point point = new Point(0,0);

void draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  ctx.strokeStyle = 'white';
  ctx.beginPath();
  ctx.arc(arc.begin.x, arc.begin.y, 3, 0, 2 * PI);
  ctx.stroke();

  if(arc.containsPoint(point)) {
    ctx.strokeStyle = 'green';
  } else {
    ctx.strokeStyle = 'red';
  }
  
  ctx.beginPath();
  arc.draw(ctx);
  ctx.stroke();
  
  if(line.containsPoint(point)) {
    ctx.strokeStyle = 'green';
  } else {
    ctx.strokeStyle = 'red';
  }
  
  ctx.beginPath();
  line.draw(ctx);
  ctx.stroke();
  
  ctx.beginPath();
  
  // ctx.rect(x, y, width, height);
}

void main() {
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
  
  Vector direction = new Vector(2,1);
  Point begin = new Point(100,100);
  arc = new ArcSegment(direction, begin, 4, 0, ArcDirection.RIGHT, 25, 90);
  Point begin2 = new Point(200,200);
  Vector direction2 = new Vector(1.5,1);
  line = new LineSegment(direction2, begin2, 4, 0, length: 200);
  arc = new ArcSegment(direction, new Point(414, 479), 4, 43, ArcDirection.LEFT, 20, 202);
  
  ctx.lineCap = 'square';
  ctx.lineWidth = arc.width;
  draw();
  
  canvas.onMouseMove.listen((MouseEvent ev) {
    point = ev.offset;
    draw();
  });
}