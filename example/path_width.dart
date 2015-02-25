import 'dart:html';

class PathSegment extends Point {
  int width;
  
  PathSegment(int x, int y, this.width) : super(x,y) {
    
  }
}

void main() {
  CanvasElement canvas = querySelector('#canvas');
  CanvasRenderingContext2D ctx = canvas.getContext('2d');
  
  List<PathSegment> path = [
    new PathSegment(0,0,6),
    new PathSegment(3,3,6),
    new PathSegment(5,5,6),
    new PathSegment(8,8,6),
    new PathSegment(10,10,1),
    new PathSegment(15,15,1),
    new PathSegment(20,20,1),
    new PathSegment(25,25,4),
    new PathSegment(50,50,4)
  ];
  
  ctx.strokeStyle = 'red';
  ctx.lineWidth = 4;
  
  ctx.beginPath(); 
  ctx.moveTo(20,20);           // Create a starting point
  ctx.lineTo(100,20);          // Create a horizontal line
  ctx.arcTo(150,20,150,70,20); // Create an arc
  ctx.lineTo(150,120);         // Continue with vertical line
  
  ctx.stroke();
  
  /*
  return;
  
  ctx.beginPath();
  
  int width = path.first.width;
  ctx.lineWidth = width;
  PathSegment last = path.first;
  ctx.moveTo(last.x, last.y);
  path.skip(1).forEach((PathSegment pathSegment) {
    if(pathSegment.width != width) {
      ctx.stroke();
      ctx.beginPath();
      width = pathSegment.width;
      ctx.lineWidth = width;
      ctx.moveTo(last.x, last.y);
    }
    ctx.lineTo(pathSegment.x, pathSegment.y);
    last = pathSegment;
  });
  
  //ctx.arcTo(last.x, last.y, x2, y2, 10);
  
  ctx.stroke();
  */
}