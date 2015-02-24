import 'dart:html';
import 'dart:math';

CanvasElement canvas;
CanvasRenderingContext2D ctx;

void main() {
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
  String color = 'red';
  
  Point position = new Point(25,25);
  
  List<Point> path = [position, new Point(20,20), new Point(14,10)];
  
  // Draw Point
  ctx.beginPath();
  ctx.fillStyle = color;
  ctx.arc(position.x, position.y, 3, 0, 2*PI);
  ctx.closePath();
  ctx.fill();
  
  // draw path & check for collision
  ctx.lineWidth = 4;
  ctx.strokeStyle = color;
  ctx.beginPath();
  ctx.moveTo(path.first.x, path.first.y);
  int i = 0;
  path.skip(1).forEach((Point p) {
    ctx.lineTo(p.x, p.y);
    detect('$i');
    i++;
  });
  ctx.stroke();
  
  detect('end');
}

void detect(String at) {
  for(int x=0;x<=canvas.width;x++) {
      for(int y=0;y<=canvas.height;y++) {
       // bool isInPath = ctx.isPointInPath(x, y);
        bool isInStroke = ctx.isPointInStroke(x, y);
        // isInPath || 
        if(isInStroke) {
          // inPath: $isInPath inStroke: $isInStroke
          print('$at $x $y');
        }
      }
    }
}