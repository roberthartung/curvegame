part of curvegame_server;

const int ROTATION_STEP = 1;

class Game {
  List<String> colors = ['red', 'green', 'yellow', 'blue', 'cyan', 'white', 'pink'];
  
  String gameId;
  
  List<Player> players;
  
  String password = null;
  
  StreamController _onEmptyController = new StreamController.broadcast();
  
  Stream get onEmpty => _onEmptyController.stream;
  
  int playerLimit = 2;
  
  Game(this.gameId, this.password) {
    players = new List<Player>();
  }
  
  bool addPlayer(Player player) {
    if(players.any((Player otherPlayer) => otherPlayer.name.toLowerCase() == player.name.toLowerCase())) {
      return false;
    }
    
    player.color = colors.removeAt(0);
    // Send player's name to every other player
    Map playerInformation = {'type': 'join', 'player': {'name': player.name, 'color': player.color, 'ready': player.isReady}};
    players.forEach((Player otherPlayer) {
      otherPlayer.send(playerInformation);
      player.send({'type':'join', 'player': {'name': otherPlayer.name, 'color': otherPlayer.color, 'ready': otherPlayer.isReady}});
    });
    players.add(player);
    if(players.first == player) {
      player.game_owner = true; 
    }
    player.send({'type':'welcome', 'player': {'name': player.name, 'color': player.color, 'ready': player.isReady}, 'game_owner': player.game_owner});
    // Send join of the player himself to add him to the list
    player.send(playerInformation);
    
    return true;
  }
  
  void removePlayer(Player player) {
    // re-add color
    colors.add(player.color);
    bool wasOwner = player == players.first;
    Player newOwner = null;
    if(wasOwner) {
      if(players.length > 1) {
        newOwner = players.skip(1).first;
      } else {
        _onEmptyController.add(this);
        print('Game finished / all players left');
      }
    }
    
    players.remove(player);
    players.forEach((Player otherPlayer) {
      otherPlayer.send({'type': 'leave', 'player': {'name': player.name}});
      if(wasOwner) {
        otherPlayer.send({'type': 'new_owner', 'player': {'name': player.name}});
      }
    });
  }
  
  void playerReadyAbort(Player player) {
    players.forEach((Player otherPlayer) {
      otherPlayer.send({'type': 'ready_abort', 'player': {'name': player.name}});
    });
  }
  
  void playerReady(Player player) {
    players.forEach((Player otherPlayer) {
      otherPlayer.send({'type': 'ready', 'player': {'name': player.name}});
    });
  }
  
  void start() {
    var allReady = true;
    players.forEach((Player player) {
      if(!player.isReady) {
        allReady = false;
      }
    });
    
    if(allReady) {
      players.forEach((Player otherPlayer) {
        otherPlayer.send({'type': 'all_ready_start'});
      });
      
      init();
      
      int delay = 5;
      new Timer.periodic(new Duration(seconds: 1), (Timer timer) {
        delay--;
        if(delay <= 0) {
          _start();
          timer.cancel();
        } else {
          players.forEach((Player otherPlayer) {
            otherPlayer.send({'type': 'countdown', 'time': delay});
          });
        }
      });
    }
  }
  
  int width = 800;
  
  int height = 800;
  
  void init() {
    print('[$gameId] Initialized');
    Random r = new Random();
    players.forEach((Player player) {
      // 100px border
      player.position = new Point(100+r.nextInt(width-200), 100+r.nextInt(height-200));
      player.angle = r.nextInt(360);
      positions[player.name] = getPlayerPosition(player);
    });
    
    sendPositions();
  }
  
  Map getPlayerPosition(Player player) {
    Map position = {};
    position['position'] = {'x': player.position.x, 'y': player.position.y};
    position['angle'] = player.angle;
    return position;
  }
  
  Map positions = {};
  
  Timer tickTimer;
  
  void _start() {
    players.forEach((Player player) {
      player.send({'type': 'start'});
    });
    
    tickTimer = new Timer.periodic(new Duration(milliseconds: 15), gameTick);
  }
  
  void sendPositions() {
    players.forEach((Player player) {
      player.send({'type': 'positions', 'positions': positions});
    });
  }
  
  /**
   * Called from Player to notify others that he is collided
   */
  
  Timer endGameTimer = null;
  
  String winningPlayer = null;
  
  void playerCollision(Player player) {
    int playersPlayingCount = 0;
    players.forEach((Player otherPlayer) {
      otherPlayer.send({'type': 'collision', 'player': {'name': player.name}});
      if(otherPlayer.isPlaying) {
        playersPlayingCount++;
        winningPlayer = otherPlayer.name;
      }
    });
    
    if(playersPlayingCount == 0) {
      print('[$gameId] No more players');
      if(endGameTimer != null && endGameTimer.isActive) {
        endGameTimer.cancel();
        endGameTimer = null;
      }
      stop();
    }
    
    if(playersPlayingCount == 1 && endGameTimer == null) {
      print('[$gameId] Only 1 player left');
      endGameTimer = new Timer(new Duration(seconds: 5), stop);
    }
  }
  
  void stop() {
    print('[$gameId] Game stopped');
    tickTimer.cancel();
    players.forEach((Player player) {
      player.send({'type': 'stop'});
      player.send({'type': 'winner', 'player': {'name': winningPlayer}});
    });
  }
  
  void gameTick(Timer t) {
    players.forEach((Player player) {
      if(player.leftKeyPressed) {
        player.angle -= ROTATION_STEP;
      }
      else if(player.rightKeyPressed) {
        player.angle += ROTATION_STEP;
      }
      
      num x = cos(player.angle/180*PI);
      num y = sin(player.angle/180*PI);
      player.direction = new Point(x,y);
      player.position -= player.direction;
      player.path.add(player.position);
      positions[player.name] = getPlayerPosition(player);
    });
    
    sendPositions();
  }
}