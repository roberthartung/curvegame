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
  
  void onData(json) {
    var data = JSON.decode(json);
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
          leftKeyPressed = true;
        break;
      case 'right_key_pressed' :
          rightKeyPressed = true;
        break;
      case 'left_key_released' :
          leftKeyPressed = false;
        break;
      case 'right_key_released' :
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