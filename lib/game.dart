part of curvegame;

class CurveGame extends SynchronizedP2PGame<LocalCurvePlayer, RemoteCurvePlayer> {
  RoomScene _roomScene;
  LoginScene _loginScene;
  GameScene _gameScene;
  
  Scene _currentScene = null;
  
  num _averagePing = 0;
  
  num _maxPing = 0;
  
  int _lastTick = 0;
  
  int get tickCount => _lastTick;
  
  PowerUpProvider _powerUpProvider;
  
  Timer _tickTimer;
  
  int get width => _width;
  int _width = 800;
  
  int get height => _height;
  int _height = 800;
  
  CurveGame() : super("ws://" + window.location.hostname + ":28080", rtcConfiguration) {
    setProtocolProvider(new CurveGameProtocolProvider(new CurveGameMessageFactory()));
    _powerUpProvider = new PowerUpProvider(this, new CurveGamePowerUpFactory(this));
    // Create Scenes
    _loginScene = new LoginScene(this);
    _roomScene = new RoomScene(this);
    _gameScene = new GameScene(this);
    // When we're connected to the signaling server, enable login
    onConnect.listen((_) {
      _loginScene.enable();
    });
    
    // Setup listeners
    onJoinRoom.listen(_onRoomJoined);
    // Set current scene
    showScene(_loginScene);
    
    new Timer.periodic(new Duration(seconds: 1), (Timer t) {
      if(_averagePing == null) {
        _averagePing = _maxPing;
      } else {
        _averagePing = _averagePing * .75 + _maxPing * .25;
      }
      _maxPing = 0;
      print('_averagePing: $_averagePing');
    });
  }

  /**
   * Show a scene
   */
  
  void showScene(Scene s) {
    if(_currentScene != null) {
      // _currentScene.disable();
    }
    _currentScene = s;
    s._show();
  }
  
  /**
   * When we're joining a room, show room scene
   */
  
  void _onRoomJoined(final SynchronizedGameRoom room) {
    room.onPlayerJoin.listen(_onPlayerJoined);
    showScene(_roomScene);
  }
  
  /**
   * A player joined the game -> create channels
   */
  
  void _onPlayerJoined(Player player) {
    if(player is RemoteCurvePlayer) {
      // Create Channels if local id is smaller than remote peer id
      if(id < player.peer.id) {
        player.peer.createChannel('chat', {'protocol': 'chat'});
        player.peer.createChannel('game', {'protocol': 'game'});
      }
      
      // Reset average ping so new players have an instant effect
      _averagePing = null;
      player.onPing.listen((int ping) {
        if(ping > _maxPing) {
          _maxPing = ping;
        }
      });
    }
  }
  
  /**
   * Starts the game
   */
  
  /*
  void startCountdown() {
    if(isOwner) {
      remotePlayers.forEach((RemoteCurvePlayer remotePlayer) {
        remotePlayer.gameChannel.send(new StartGameMessage());
      });
    }
    
    showScene(_gameScene);
    
    int count = 5;
    new Timer.periodic(new Duration(seconds: 1), (Timer t) {
      count--;
      if(count == 0) {
        t.cancel();
        _start();
      }
    });
  }
  */
  
  /**
   * High resolution start time
   */
  
  /*
  double _startTime;
  
  void _start() {
    print('Start Game!');
    // _tickTimer = new Timer.periodic(new Duration(milliseconds: TICK_DELAY), _tick);
    window.requestAnimationFrame(_render);
    _startTime = window.performance.now();
  }
  
  void _render(num time) {
    window.requestAnimationFrame(_render);
    int currentTick = (time - _startTime) ~/ TICKS_PER_SECONDS;
    while(_lastTick <= currentTick) {
      players.where((Player player) => player.isAlive).forEach((Player player) => player.tick(_lastTick)); 
      _powerUpProvider.tick(_lastTick);
      _lastTick++;
    }
  }
  */
  
  @override
  CurveGameRoom createGameRoom(Room room) {
    return new CurveGameRoom(this, room);
  }
}
