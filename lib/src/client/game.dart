part of curvegame.client;

class Game extends common.Game<Player> {
  // List<client.Player> curves = new List<client.Player>();
  CanvasElement canvas;
  
  CanvasRenderingContext2D ctx;
  
  Rectangle gameArea;
  
  ButtonElement readyButton;
  
  WebSocket webSocket;
  
  // bool isReady = false;
  
  Player localPlayer = null;
  
  bool isGameOwner = false;
  
  UListElement playersList;
  
  // String localPlayerName;
  
  Map<String, Player> playersMap = {};
  
  String myPlayerColor = 'red';
  
  bool started = false;
  
  Map<int,PowerUp> powerUps = {};
  
  Game(String gameId, String password, this.webSocket, bool this.isGameOwner) : super(gameId, password) {
    players = new List<Player>();
    canvas = querySelector('#canvas');
    ctx = canvas.getContext('2d');
    gameArea = new Rectangle(0, 0, canvas.width, canvas.height);
    readyButton = querySelector('#ready');
    playersList = querySelector('#players');
    if(isGameOwner) {
      readyButton.text = 'Waiting for other players';
      readyButton.disabled = true;
    }
    webSocket.onMessage.listen(onMessage);
    
    readyButton.onClick.listen(onReadyButtonClick);
    
    document.onKeyDown.listen(onKeyDown);
    document.onKeyUp.listen(onKeyUp);
  }
  
  void onReadyButtonClick(MouseEvent ev) {
    // If local player was not ready before -> now ready
    // Status will be updated after message from server
    if(!localPlayer.isReady) {
      webSocket.sendString(JSON.encode({'type': 'ready'}));
      readyButton.text = 'Ready';
    } else {
      webSocket.sendString(JSON.encode({'type': 'ready_abort'}));
      readyButton.text = 'Not Ready';
    }
  }
  
  void onKeyUp(KeyboardEvent ev) {
    if(localPlayer == null || !localPlayer.isPlaying) {
      return;
    }
    
    ev.preventDefault();
    switch(ev.keyCode) {
      case KeyCode.LEFT :
        webSocket.send(JSON.encode({'type': 'left_key_released'}));
        leftKeyPressed = false;
      break;
      case KeyCode.RIGHT :
        webSocket.send(JSON.encode({'type': 'right_key_released'}));
        rightKeyPressed = false;
        break;
    }
  }
  
  void onKeyDown(KeyboardEvent ev) {
    if(localPlayer == null || !localPlayer.isPlaying) {
      return;
    }
    
    ev.preventDefault();
    switch(ev.keyCode) {
      case KeyCode.LEFT :
        if(!leftKeyPressed) {
          webSocket.send(JSON.encode({'type': 'left_key_pressed'}));
          leftKeyPressed = true;
        }
      break;
      case KeyCode.RIGHT :
        if(!rightKeyPressed) {
          webSocket.send(JSON.encode({'type': 'right_key_pressed'}));
          rightKeyPressed = true;
        }
        break;
    }
  }
  
  void addPlayer(Player player) {
    playersList.append(player.li);
    players.add(player);
    playersMap[player.name] = player;
  }
  
  Player getPlayer(Map data) {
    return getPlayerByName(data['player']['name']);
  }
  
  Player getPlayerByName(String name) {
      return playersMap[name];
    }
  
  void onMessage(MessageEvent ev) {
    Map data = JSON.decode(ev.data);
    //print("message type: ${data['type']}");
    switch(data['type']) {
      case "join" :
        Player player = new Player.fromObject(data['player'], this);
        if(localPlayer == null) {
          player.isLocal = true;
          localPlayer = player;
        }
        addPlayer(player);
        break;
      case "leave" :
        Player player = getPlayer(data);
        player.li.remove();
        playersMap.remove(player.name);
        players.remove(player);
        break;
      case "ready" :
        // Message is only received if a different player is ready
        Player player = getPlayer(data);
        player.setReady(true);
        
        // Only check if we're the game owner
        if(isGameOwner) {
          // Check if all OTHER players are ready
          bool otherPlayersReady = true;
          playersMap.forEach((String playerName, Player player) {
            // Cancel if one non local player is not ready
            if(!player.isLocal && !player.isReady) {
              otherPlayersReady = false;
            }
          });
          
          // Ability to start the game if all other players are ready
          if(otherPlayersReady) {
            readyButton.disabled = false;
            readyButton.text = 'Start game';
          }
        }
        break;
      case "ready_abort" :
        Player player = getPlayer(data);
        player.setReady(false);
        
        if(isGameOwner) {
          readyButton.disabled = true;
          readyButton.text = 'Waiting for other players';
        }
        break;
      // All player are ready and game will start soon
      case "all_ready_start" :
        readyButton.disabled = true;
        readyButton.text = 'Game starts in 5';
        
        /*
        playersMap.forEach((String playerName, Map data) {
          client.Player curve = new client.Player(playerName, data['color'], gameArea, playerName == localPlayerName ? webSocket : null);
          if(playerName == localPlayerName) {
            curve.isLocal = true;
          }
          players[playerName]['curve'] = curve;
          curves.add(curve);
        });
        */
        break;
      case "stop" :
        print('game stopped');
        if(pingTimer != null) {
          pingTimer.cancel();
          pingTimer = null;
        }
        started = false;
        readyButton.disabled = false;
        readyButton.classes.remove('abort');
        readyButton.classes.add('ready');
        // Reset ready status
        webSocket.sendString(JSON.encode({'type': 'ready_abort'}));
        if(isGameOwner) {
          readyButton.disabled = true;
          readyButton.text = 'Waiting for other players';
        } else {
          readyButton.text = 'Not Ready';
        }
        break;
      case "collision" :
        Player player = getPlayer(data);
        player.isPlaying = false;
        print('[${player.name}] Collision.');
        break;
      case "countdown" :
        readyButton.text = 'Game starts in ${data['time']}';
        break;
      case "spawn_powerup" :
        print('power up spawned: $data');
        PowerUp powerUp = PowerUp.instanceFomObject(data['powerup']);
        powerUps[powerUp.id] = powerUp;
        // TODO(rh)
        // = new PowerUp.fromObject(data['powerup']);
        //
        break;
      case "collect_powerup" :
        // Player collected a PowerUp
        powerUps.remove(data['powerup']['id']);
        break;
      case "current_segment" :
        Player player = getPlayer(data);
        print('[${player.name}] Current Segment received');
        if(data.containsKey("arc")) {
          player.currentSegment = new common.ArcSegment.fromObject(data['arc']);
        } else if(data.containsKey("line")) {
          player.currentSegment = new common.LineSegment.fromObject(data['line']);
        } else {
          print('[ERROR] Current Segment wrong');
        }
        break;
      case "segment" :
        Player player = getPlayer(data);
        if(player.isPlaying) {
          if(data.containsKey("arc")) {
            //print('[${player.name}] arc segment');
            player.pathSegments.add(new common.ArcSegment.fromObject(data['arc']));
          } else if(data.containsKey("line")) {
            //print('[${player.name}] line segment');
            player.pathSegments.add(new common.LineSegment.fromObject(data['line']));
          }
        }
        break;
      case "positions" :
          (data['positions'] as Map<String, Map>).forEach((String playerName, Map info) {
            Player player = getPlayerByName(playerName);
            num stepAngle = info.containsKey('arc') ? info['arc']['angle'] : null;
            num stepLength = info.containsKey('line') ? info['line']['length'] : null;
            player.step(new Point(info['position']['x'], info['position']['y']), stepAngle: stepAngle, stepLength: stepLength);
          });
          
          if(!started) {
            draw();
            // TODO(rh): Start loop for drawing arrows and local positions
          }
        break;
      case "pong" :
        int ping = new DateTime.now().millisecondsSinceEpoch - pingStart;
        querySelector('#ping').text = '$ping';
        print('ping: ${ping}ms');
        break;
      case "start":
        started = true;
        readyButton.text = 'Game started';
        start();
        break;
      default :
        print(data);
        break;
    }
  }
  
  void gameLoop(num frame) {
    // int seconds = (frame ~/ 60);
    draw();
    
    if(started) {
      window.requestAnimationFrame(gameLoop);
    }
  }

  void checkCollision(Player player) {
    // Check all other playing curves if they collide with the current drawn path
    players.where((Player otherPlayer) => (otherPlayer != player && otherPlayer.isPlaying)).forEach((Player otherPlayer) {
      // Check if anyone is colliding with use
      //int start = new DateTime.now().millisecond;
      if(ctx.isPointInStroke(otherPlayer.position.x, otherPlayer.position.y)) {
        // If collision is detection always stop playing for that curve
        print('[${player.name}] stopped playing.');
        otherPlayer.isPlaying = false;
        if(otherPlayer.isLocal) {
          otherPlayer.collision('stroke');
          print('[${otherPlayer.name}] Collsion with ${player.name}');
        }
      }
     //print((new DateTime.now().millisecond) - start);
    });
  }

  void draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
   
    powerUps.forEach((int id, PowerUp powerUp) {
      ctx.save();
      powerUp.draw(ctx);
      ctx.restore();
    });
    
    // Render old path
    players.forEach((Player player) {
      ctx.save();
      player.draw(ctx);
      checkCollision(player);
      // c.step();
      ctx.restore();
    });
  }
  
  /**
   * Start current game
   */
  
  bool leftKeyPressed = false;
  bool rightKeyPressed = false;
  
  Timer pingTimer = null;
  
  int pingStart;
  
  void start() {
    window.requestAnimationFrame(gameLoop);
    pingTimer = new Timer.periodic(new Duration(seconds: 1), (Timer t) {
      pingStart = new DateTime.now().millisecondsSinceEpoch;
      webSocket.send(JSON.encode({'type': 'ping', 'time': pingStart}));
    });
  }
}