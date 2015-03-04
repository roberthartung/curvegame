part of curvegame.client;

class Player extends common.Player<Game> {
  bool isLocal = false;
  
  LIElement li;
  
  int points = 0;
  
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
  
  void setReady(bool ready) {
    print('$name is ready: $ready');
    isReady = ready;
    li.querySelector('.ready i').classes.toggleAll(['fa-check', 'fa-times']);
  }
  
  /**
   * Make a step
   */
  
  // common.PathSegment newSegment
  
  bool step(Point newPosition, {stepAngle: null, stepLength: null}) {
    if(!isPlaying) {
      return false;
    }
    
    position = newPosition;
    if(stepAngle != null && currentSegment is common.ArcSegment) {
      (currentSegment as common.ArcSegment).angle = stepAngle;
    } else if(stepLength != null && currentSegment is common.LineSegment) {
      (currentSegment as common.LineSegment).length = stepLength;
    } else {
      print('[ERROR] WRONG STEP INFORMATION (ANGLE/LENGTH). angle: $stepAngle length: $stepLength segment: $currentSegment');
    }
    // TODO(rh): More dynamic points calculation
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
    isPlaying = false;
    game.webSocket.send(JSON.encode({'type':'collision', 'reason': reason}));
  }
  
  void drawPathSegment(CanvasRenderingContext2D ctx, common.PathSegment segment) {
    ctx.save();
    ctx.lineWidth = segment.width;
    ctx.beginPath();
    segment.draw(ctx);
    ctx.stroke();
    // TODO(rh): Collision detection!
    
    game.players.where((Player otherPlayer) => otherPlayer.isPlaying).forEach((Player otherPlayer) {
      
    });
    
    ctx.restore();
  }
  
  /**
   * Check a segment against this player's position
   * TODO(rh): Use web worker for collision detection later!
   */
  
  bool collisionDetection(Player otherPlayer, common.PathSegment segment) {
    // If there actually is a collision possible
    if(segment.containsPoint(position)) {
      num distanceDifference = currentSegment.getTotalDistance() - segment.getTotalDistance(); 
      //print('[Segment contains point] position: $position distanceDifference: $distanceDifference segment: $segment');
      // Collision if the player is different or the distance is greater than 5
      if(otherPlayer != this || distanceDifference > 5) {
        isPlaying = false;
        print('[${name}] collision');
        if(isLocal) {
          collision('$name');
        }
      }
    }
    
    return false;
  }
  
  bool draw(CanvasRenderingContext2D ctx) {
    // color
    ctx.fillStyle = color;
    ctx.strokeStyle = color;
    
    // Draw current position
    ctx.beginPath();
    ctx.arc(position.x, position.y, 3, 0, 2*PI);
    ctx.closePath(); // needed?
    ctx.fill();
    
    // draw path & check for collision
    // older path segments
    pathSegments.forEach((common.PathSegment segment) {
      drawPathSegment(ctx, segment);
      // For each player check collision with this segment
      game.players.where((Player otherPlayer) => otherPlayer.isPlaying).forEach((Player otherPlayer) {
        otherPlayer.collisionDetection(this, segment);
      });
    });
    // current segment
    game.players.where((Player otherPlayer) => otherPlayer.isPlaying).forEach((Player otherPlayer) {
      otherPlayer.collisionDetection(this, currentSegment);
    });
    // collision detection with currentSegment!
    // Current segment
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