import 'dart:math' as math;
import 'dart:html';
import 'package:curvegame/common.dart' as common;

void main() {
  CanvasElement canvas = querySelector('#canvas');
  CanvasRenderingContext2D ctx = canvas.getContext('2d');
  
  common.Vector direction = new common.Vector(2,1);
  math.Point begin = new math.Point(100,100);
  common.ArcSegment arc = new common.ArcSegment(direction, begin, 4, common.ArcDirection.RIGHT, 25, 90);
  math.Point begin2 = new math.Point(200,200);
  common.Vector direction2 = new common.Vector(1.5,1);
  common.LineSegment line = new common.LineSegment(direction2, begin2, 4, distance: 50);
  
  ctx.lineCap = 'square';
  ctx.strokeStyle = 'red';
  ctx.lineWidth = arc.width;
  ctx.beginPath();
  arc.draw(ctx);
  ctx.stroke();
  
  ctx.beginPath();
  line.draw(ctx);
  ctx.stroke();
  
  canvas.onMouseMove.listen((MouseEvent ev) {
    if(arc.containsPoint(ev.offset)) {
      print(ev.offset);
    }
    
    if(line.containsPoint(ev.offset)) {
      print(ev.offset);
    }
  });
}