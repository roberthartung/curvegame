part of curvegame_server;

class Player {
  WebSocket webSocket;
  
  Game game;
  
  String name;
  
  bool game_owner = false;
  
  bool isReady = false;
  
  Stream dataStream;
  
  String color = 'red';
  
  bool leftKeyPressed = false;
    
  bool rightKeyPressed = false;
  
  Point position;
  
  Point direction;
  
  num angle;
  
  bool isPlaying = true;
  
  List<Point> path = [];
  
  Player(this.game, this.dataStream, this.webSocket, this.name) {
    webSocket.done.then((d) {
      game.removePlayer(this);
    });
    
    dataStream.listen(onData);
  }
  
  void send(Object o) {
    webSocket.add(JSON.encode(o));
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