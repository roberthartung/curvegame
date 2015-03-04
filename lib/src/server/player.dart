part of curvegame.server;

class Player extends common.Player<Game> {
  WebSocket _webSocket;
  
  Stream _dataStream;
  
  bool _leftKeyPressed = false;
    
  bool _rightKeyPressed = false;
  
  /**
   * Parameters, influenced by [PowerUp]s
   */
  
  num lineStep = common.LINE_STEP;
    
  num arcStep = common.ROTATION_STEP;
  
  bool inverted = false;
  
  Player(name, Game game, this._dataStream, this._webSocket) : super(name, game) {
    _webSocket.done.then((d) {
      game.removePlayer(this);
    });
    
    _dataStream.listen(onData);
  }
  
  /**
   * Sends an object as JSON to this [Player]
   */
  
  void send(Object o) {
    //print('[$name] send($o)');
    try {
      _webSocket.add(JSON.encode(o, toEncodable: (dynamic obj) {
        // TODO(rh): Why is obj not recognized as a PowerUp?
        if(obj is PowerUp) {
          return obj.toObject();
        }
        
        print('[ERROR] Unknown object to encode $obj/${obj.runtimeType} ${reflect(obj).type.location})');
        return null;
      }));
    } catch(ex) {
      print('Exception: $ex');
    }
  }
  
  /**
   * Sends old segment to players and gets new position + direction from last segment
   */
  
  void checkDirection() {
    if(!game.isRunning) {
      return;
    }
    
    // Notify others about old segment first
    Map oldSegment = currentSegment.toObject();
    Map message = {'type': 'segment', 'player': {'name': name}};
    if(currentSegment is common.ArcSegment) {
      message['arc'] = oldSegment;
    } else if(currentSegment is common.LineSegment) {
      message['line'] = oldSegment;
    }
    // send old segment to other players
    game.players.forEach((Player player) {
      player.send(message);
    });
    
    // Take direction from last point of arc
    if(currentSegment is common.ArcSegment) {
      common.ArcSegment arc = currentSegment;
      direction = arc.getEndDirection();
      position = arc.getEndPoint();
      distance += 2 * PI * arc.radius * arc.angle / 360;
    } else if(currentSegment is common.LineSegment) {
      common.LineSegment line = currentSegment;
      distance += line.length;
    }
  }
  
  /**
   * Make a tick within the game that is: move line or arc and get new position
   * 
   * Collision detection will be performed in clients
   */
  
  void tick() {
    if(currentSegment is common.LineSegment) {
      common.LineSegment line = currentSegment;
      line.length += lineStep;
    } else if(currentSegment is common.ArcSegment) {
      // In case of an arc increase angle
      common.ArcSegment arc = currentSegment;
      arc.angle += arcStep;
    }
    
    position = currentSegment.getEndPoint();
  }
  
  /**
   * Begin new arc
   */
  
  void beginArc(common.ArcDirection arcDirection) {
    checkDirection();
    // If the user is inverted, switch direction
    if(inverted) {
      arcDirection = arcDirection == common.ArcDirection.LEFT ? common.ArcDirection.RIGHT : common.ArcDirection.LEFT;
    }
    // Start with higher angle (4) so player sees instant change
    currentSegment = new common.ArcSegment(direction, position, game.lineWidth, distance, arcDirection, common.DEFAULT_ARC_RADIUS, 4);
    sendCurrentSegment();
  }
  
  /**
   * Begin line
   */
  
  void beginLine() {
    checkDirection();
    currentSegment = new common.LineSegment(direction, position, game.lineWidth, distance);
    sendCurrentSegment();
  }
  
  /**
   * Send current segment of this [Player] to all players
   */
  
  void sendCurrentSegment() {
    Map message = {'type': 'current_segment', 'player': {'name': name}};
    if(currentSegment is common.LineSegment) {
      message['line'] = currentSegment.toObject();
    } else if(currentSegment is common.ArcSegment) {
      message['arc'] = currentSegment.toObject();
    }
    
    game.players.forEach((Player player) {
      player.send(message);
    });
  }
  
  /**
   * Called when data received
   */
  
  void onData(json) {
    var data = JSON.decode(json);
    switch(data['type']) {
      case 'ready' :
        game.playerReady(this);
        isReady = true;
        
        // Ready can only be send if all other players are ready
        // so if this is the game owner: everyone is ready
        if(game_owner) {
          game.start();
        }
        break;
      case 'ready_abort' :
        isReady = false;
        game.playerReadyAbort(this);
        break;
      case 'left_key_pressed' :
        if(!_leftKeyPressed) {
          beginArc(common.ArcDirection.LEFT);
          _leftKeyPressed = true;
        }
        break;
      case 'right_key_pressed' :
        if(!_rightKeyPressed) {
          beginArc(common.ArcDirection.RIGHT);
          _rightKeyPressed = true;
        }
        break;
      case 'left_key_released' :
        beginLine();
        _leftKeyPressed = false;
        break;
      case 'right_key_released' :
        beginLine();
        _rightKeyPressed = false;
        break;
      case 'collision' :
        isPlaying = false;
        game.playerCollision(this);
        print('collision for $name reason: ${data['reason']}');
        break;
      case 'ping' :
        send({'type': 'pong'});
        break;
    }
  }
}