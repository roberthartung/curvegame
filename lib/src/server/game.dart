part of curvegame.server;

class Game extends common.Game<Player> {
  List<String> colors = ['red', 'green', 'yellow', 'blue', 'cyan', 'white', 'pink'];
  
  StreamController _onEmptyController = new StreamController.broadcast();
  
  Stream get onEmpty => _onEmptyController.stream;
  
  int playerLimit = 2;
  
  Map positions = {};
  
  Timer tickTimer;
  
  Timer endGameTimer = null;
  
  String winningPlayer = null;
  
  // First spawn after 5 seconds
  int nextPowerUpSpawnTick = common.TICKS_PER_SECONDS*5;
  
  List<ClassMirror> availablePowerUps = [];
  
  bool _running = false;
  
  bool get isRunning => _running == true;
  
  int lineWidth = common.DEFAULT_LINE_WIDTH;
     
  //common.DrawablePowerUp powerUp = null;

  Game(gameId, password) : super(gameId, password) {
    players = new List<Player>();
    TypeMirror baseClass = reflectType(PowerUp);
    (baseClass.owner as LibraryMirror).declarations.forEach((Symbol s, DeclarationMirror decl) {
      if(decl is ClassMirror && !decl.isAbstract && decl.isSubtypeOf(baseClass)) {
        availablePowerUps.add(decl);
      }
    });
    print('availablePowerUps: $availablePowerUps');
  }
  
  bool addPlayer(Player player) {
    if(players.any((Player otherPlayer) => otherPlayer.name.toLowerCase() == player.name.toLowerCase())) {
      return false;
    }
    
    print('[$gameId] Player ${player.name} added');
    
    player.color = colors.removeAt(0);
    if(players.length == 0) {
      player.game_owner = true;
    }
    
    // Welcome
    print('Send welcome to ${player.name}');
    player.send({'type':'welcome', 'player': {'name': player.name, 'color': player.color, 'ready': player.isReady}, 'game_owner': player.game_owner});
    
    Map playerInformation = {'type': 'join', 'player': {'name': player.name, 'color': player.color, 'ready': player.isReady}};
    
    // Send join of the player himself to add him to the list
    // Send it here because the first joined player will be taken as the local player
    player.send(playerInformation);
    
    // Exchange player information with other players
    // One message to each other player
    // One message per current player to new player
    players.forEach((Player otherPlayer) {
      otherPlayer.send(playerInformation);
      player.send({'type':'join', 'player': {'name': otherPlayer.name, 'color': otherPlayer.color, 'ready': otherPlayer.isReady}});
    });
    
    players.add(player);
    
    
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
  
  void init() {
    Random r = new Random();
    players.forEach((Player player) {
      // 100px border, random position
      player.position = new Point(100+r.nextInt(width-200), 100+r.nextInt(height-200));
      // Direction
      num angle = r.nextInt(360);
      double radians = angle/180*PI;
      player.direction = new common.Vector(cos(radians), sin(radians));
      // Create first line segment
      // player.currentSegment = new common.LineSegment(player.direction, player.position, common.DEFAULT_LINE_WIDTH, 0);
      player.beginLine();
      positions[player.name] = getPlayerPosition(player);
    });
    
    sendPositions();
    
    print('[$gameId] Initialized');
  }
  
  void sendPositions() {
    players.forEach((Player player) {
      player.send({'type': 'positions', 'positions': positions});
    });
  }
  
  Map getPlayerPosition(Player player) {
    Map position = {};
    position['position'] = {'x': player.position.x, 'y': player.position.y};
    if(player.currentSegment is common.ArcSegment) {
      common.ArcSegment arc = player.currentSegment as common.ArcSegment;
      position['arc'] = {'angle': arc.angle};
    } else if(player.currentSegment is common.LineSegment) {
      common.LineSegment line = player.currentSegment as common.LineSegment;
      position['line'] = {'length': line.length};
    } else {
      print('[ERROR] Unable to get player position for ${player.name}');
    }
    return position;
  }
  
  void _start() {
    _running = true;
    players.forEach((Player player) {
      player.send({'type': 'start'});
    });
    
    tickTimer = new Timer.periodic(new Duration(milliseconds: common.TICK_DELAY), gameTick);
  }
  
  /**
   * Called from Player to notify others that he is collided
   */
  
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
  
  /**
   * Stop the game
   */
  
  void stop() {
    _running = false;
    print('[$gameId] Game stopped');
    tickTimer.cancel();
    players.forEach((Player player) {
      player.send({'type': 'stop'});
      player.send({'type': 'winner', 'player': {'name': winningPlayer}});
    });
  }
  
  List<PowerUp> powerUps = [];
  
  List<PowerUp> activePowerUps = [];
  
  int _powerUpId = 0;
  
  void spawnPowerUp() {
    Random random = new Random();
    int id = _powerUpId++;
    Point position = new Point(random.nextInt(width), random.nextInt(height));
    availablePowerUps.shuffle();
    PowerUp powerUp = availablePowerUps.first.newInstance(new Symbol(''), [id, position]).reflectee;
    powerUps.add(powerUp);
    players.forEach((Player player) {
      player.send({'type': 'spawn_powerup', 'powerup': powerUp});
    });
  }
  
  /**
   * Makes a tick in the game
   */
  
  void gameTick(Timer t) {
    tickCount++;
    
    if(tickCount == nextPowerUpSpawnTick) {
      spawnPowerUp();
      Random random = new Random();
      nextPowerUpSpawnTick = tickCount + common.TICKS_PER_SECONDS * (3 + random.nextInt(5));
    }
    
    // Check active power ups
    List<PowerUp> finishedPowerUps = [];
    activePowerUps.forEach((PowerUp powerUp) {
      if(powerUp.tick(tickCount)) {
        print('[PowerUp] $powerUp finished.');
        finishedPowerUps.add(powerUp);
      }
    });
    activePowerUps.removeWhere((common.PowerUp e) => finishedPowerUps.contains(e));
    
    positions = {};
    
    // One tick for each player
    players.forEach((Player player) {
      // Only make tick for player if playing
      if(player.isPlaying) {
        // If it's a line simply increase the distance
        player.tick();
        positions[player.name] = getPlayerPosition(player);
        
        // Check if a power up was collected
        List<PowerUp> powerUpsToRemove = [];
        powerUps.forEach((PowerUp powerUp) {
          // 15 = radius of circle around icon
          // TODO(rh): Make 15 a const
          if(powerUp.position.distanceTo(player.position) <= 15) {
            powerUpCollected(powerUp, player);
            powerUpsToRemove.add(powerUp);
          }
        });
        powerUps.removeWhere((common.PowerUp e) => powerUpsToRemove.contains(e));
        powerUpsToRemove.clear();
      }
    });
    
    sendPositions();
  }
  
  /**
   * A [Player] collected a [PowerUp]
   */
  
  void powerUpCollected(PowerUp powerUp, Player player) {
    activePowerUps.add(powerUp);
    // Depending on the type, some actions have to be taken
    powerUp.collected(player);
    print('[PowerUp] Player ${player.name} collected $powerUp');
    players.forEach((Player player) {
      player.send({'type': 'collect_powerup', 'powerup': powerUp});
    });
  }
}