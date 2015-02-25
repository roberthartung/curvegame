part of curvegame.client;

class Player extends common.Player<Game> {
  bool isLocal = false;
  
  LIElement li;
  
  Player.fromObject(Map data, Game game) : super(data['name'], game) {
    this.color = data['color'];
    // TODO(rh): ready
    li = new LIElement();
    li.classes.add('player');
    li.appendHtml('''<span class="color $color"></span>
  <span class="ready"><i class="fa fa-'''+(isReady ? 'check' : 'times')+'''"></i></span>
  <span class="name">$name</span>
  <span class="points">0</span>''');
  }
  
  int points = 0;
  
  void setReady(bool ready) {
    print('$name is ready: $ready');
    isReady = ready;
    li.querySelector('.ready i').classes.toggleAll(['fa-check', 'fa-times']);
  }
  
  bool step(Point newPosition, common.PathSegment newSegment) {
    if(!isPlaying) {
      return false;
    }
    
    position = newPosition;
    currentSegment = newSegment;
    points++;
    
    li.querySelector('.points').text = '${points}';
    
    bool isInside = game.gameArea.containsPoint(position);
    if(!isInside) {
      // Always immedeately stop other players
      print('[$name] Stopped playing (area).');
      isPlaying = false;
      if(isLocal) {
        collision('area');
      }
    }
    
    return isPlaying;
  }
  
  void collision(String reason) {
    game.webSocket.send(JSON.encode({'type':'collision', 'reason': reason}));
  }
  
  void drawPathSegment(CanvasRenderingContext2D ctx, common.PathSegment segment) {
    ctx.save();
    ctx.lineWidth = segment.width;
    ctx.beginPath();
    segment.draw(ctx);
    ctx.stroke();
    // TODO(rh): Collision detection!
    ctx.restore();
  }
  
  bool draw(CanvasRenderingContext2D ctx) {
    // Draw Point
    
    ctx.fillStyle = color;
    ctx.strokeStyle = color;
    
    // Draw current position
    ctx.beginPath();
    // TODO(rh): Get Position from line/segment
    ctx.arc(position.x, position.y, 3, 0, 2*PI);
    ctx.closePath(); // needed?
    ctx.fill();
    
    // draw path & check for collision
    
    pathSegments.forEach((common.PathSegment segment) => drawPathSegment(ctx, segment));
    drawPathSegment(ctx, currentSegment);
    
    /*
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(path.first.x, path.first.y);
    int offset = 0;
    int lastPointToCheck = path.length - 3;
    path.skip(1).forEach((Point p) {
      offset++;
      ctx.lineTo(p.x, p.y);
      if(isLocal && isPlaying && offset == lastPointToCheck) {
        //int start = new DateTime.now().millisecond;
        if(ctx.isPointInStroke(position.x, position.y)) {
          isPlaying = false;
          collision('self');
          print('[$name] Collsion with own curve');
        }
        //print((new DateTime.now().millisecond) - start);
      }
    });
    ctx.stroke();
    */
    
    return false;
  }
}