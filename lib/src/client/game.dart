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
  List<common.DrawableEntity> entities = [];
  
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
    
    readyButton.onClick.listen((MouseEvent ev) {
      // If local player was not ready before -> now ready
      // Status will be updated after message from server
      if(!localPlayer.isReady) {
        webSocket.sendString(JSON.encode({'type': 'ready'}));
        readyButton.text = 'Ready';
      } else {
        webSocket.sendString(JSON.encode({'type': 'ready_abort'}));
        readyButton.text = 'Not Ready';
      }
    });
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
    var data = JSON.decode(ev.data);
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
        /*
        client.Player curve = (players[json['player']['name']]['curve'] as client.Player);
        curve.isPlaying = false;
        */
        break;
      case "countdown" :
        readyButton.text = 'Game starts in ${data['time']}';
        break;
      case "entity_spawn" :
        common.DrawableEntity entity = new common.DrawableEntity.fromObject(data['entity']);
        entities.add(entity);
        break;
        // Player collected an entity
      case "entity_collect" :
        // Player collected a entity
        break;
      case "positions" :
          (data['positions'] as Map<String, Map>).forEach((String playerName, Map info) {
            Player player = getPlayerByName(playerName);
            player.step(new Point(info['position']['x'], info['position']['y']));
            //print('position of player $playerName: $info');
            // client.Player curve = (players[playerName]['curve'] as client.Player);
            //curve.step();
            //LIElement li = players[playerName]['li'];
          });
          
          if(!started) {
            draw();
          }
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
   
    entities.forEach((common.DrawableEntity entity) {
      ctx.save();
      
      ctx.fillStyle = 'green';
      ctx.beginPath();
      ctx.arc(entity.x, entity.y, 15, 0, 2*PI);
      ctx.closePath();
      ctx.fill();
      
      // TODO(rh): Color/Target from entity
      ctx.font = '20px FontAwesome';
      ctx.textBaseline = 'top';
      ctx.textAlign = 'left';
      ctx.fillStyle = 'white';
      TextMetrics metrics = ctx.measureText(entity.iconText);
      ctx.fillText(entity.iconText, entity.x - metrics.width/2, entity.y-10);
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
  
  void start() {
    window.requestAnimationFrame(gameLoop);

    document.onKeyDown.listen((KeyboardEvent ev) {
      ev.preventDefault();
      switch(ev.keyCode) {
        case KeyCode.LEFT :
          webSocket.send(JSON.encode({'type': 'left_key_pressed'}));
        break;
        case KeyCode.RIGHT :
          webSocket.send(JSON.encode({'type': 'right_key_pressed'}));
          break;
      }
    });
    
    document.onKeyUp.listen((KeyboardEvent ev) {
      ev.preventDefault();
      switch(ev.keyCode) {
        case KeyCode.LEFT :
          webSocket.send(JSON.encode({'type': 'left_key_released'}));
        break;
        case KeyCode.RIGHT :
          webSocket.send(JSON.encode({'type': 'right_key_released'}));
          break;
      }
    });
  }
}