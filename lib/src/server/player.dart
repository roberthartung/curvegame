part of curvegame.server;

class Player extends common.Player<Game> {
  WebSocket webSocket;
  
  Stream dataStream;
  
  bool leftKeyPressed = false;
    
  bool rightKeyPressed = false;  
  
  Player(name, Game game, this.dataStream, this.webSocket) : super(name, game) {
    webSocket.done.then((d) {
      game.removePlayer(this);
    });
    
    dataStream.listen(onData);
  }
  
  void send(Object o) {
    try {
      webSocket.add(JSON.encode(o, toEncodable: (obj) {
        if(obj is common.Entity) {
          return obj.toObject();
        }
        
        print('Unknown object to encode');
        
        return {'error': 'encoding_error'};
      }));
    } catch(ex) {
      print('Exception: $ex');
    }
  }
  
  void checkDirection() {
    // Notify others about new segment
    Map oldSegment = currentSegment.toObject();
    Map message = {'type': 'segment', 'player': {'name': name}};
    if(currentSegment is common.ArcSegment) {
      message['arc'] = oldSegment;
    } else if(currentSegment is common.LineSegment) {
      message['line'] = oldSegment;
    }
    game.players.forEach((Player player) {
      player.send(message);
    });
    
    // Take direction from last point of arc
    if(currentSegment is common.ArcSegment) {
      common.ArcSegment arc = currentSegment;
      direction = arc.getEndDirection();
      position = arc.getEndPoint();
    }
  }
  
  void beginArc(common.ArcDirection arcDirection) {
    checkDirection();
    currentSegment = new common.ArcSegment(direction, position, common.DEFAULT_LINE_WIDTH, arcDirection, common.DEFAULT_ARC_RADIUS, 0);
  }
  
  void beginLine() {
    checkDirection();
    currentSegment = new common.LineSegment(direction, position, common.DEFAULT_LINE_WIDTH);
  }
  
  void onData(json) {
    var data = JSON.decode(json);
    print("$name ${data['type']}");
    switch(data['type']) {
      case 'ready' :
        game.playerReady(this);
        isReady = true;
        
        if(game_owner) {
          game.start();
        }
        break;
      case 'ready_abort' :
        isReady = false;
        game.playerReadyAbort(this);
        break;
      case 'left_key_pressed' :
        if(!leftKeyPressed) {
          beginArc(common.ArcDirection.LEFT);
          leftKeyPressed = true;
        }
        break;
      case 'right_key_pressed' :
        if(!rightKeyPressed) {
          beginArc(common.ArcDirection.RIGHT);
          rightKeyPressed = true;
        }
        break;
      case 'left_key_released' :
        beginLine();
        leftKeyPressed = false;
        break;
      case 'right_key_released' :
        beginLine();
        rightKeyPressed = false;
        break;
      case 'collision' :
        isPlaying = false;
        game.playerCollision(this);
        print('collision for $name reason: ${data['reason']}');
        break;
    }
  }
}