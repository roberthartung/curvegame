library curvegame;

import 'dart:html';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
//import "dart:isolate";
// import 'package:curvegame/DouglasPeucker.dart';

List<Curve> curves = new List<Curve>();
CanvasElement canvas;
CanvasRenderingContext2D ctx;
Rectangle gameArea;
ButtonElement readyButton;
WebSocket webSocket;
bool isReady = false;
bool isGameOwner = false;
UListElement playersList;
Map<String, Map> players = {};
String myPlayerColor = 'red';
bool started = false;


class Curve {
  bool isLocal = false;
  
  List<Point> path = new List<Point>();
  
  Point position;
  
  String color;
  
  String name;
  
  bool isPlaying = true;
  
  Curve(String this.name, String this.color);
  
  int points = 0;
  
  bool step(Point newPosition) {
    if(!isPlaying) {
      return false;
    }
    
    points++;
    position = newPosition;
    path.add(position);
    
    // 0.1px tolerance
    //path = DouglasPeucker.douglasPeucker(path, 0.001);
    
    //print('step for $name at $position ${path.length}');
    
    bool isInside = gameArea.containsPoint(position);
    if(!isInside) {
      // Always immedeately stop other players
      print('[$name] stopped playing (area).');
      isPlaying = false;
      if(isLocal) {
        collision('area');
      }
    }
    
    return isPlaying;
  }
  
  void collision(String reason) {
    webSocket.send(JSON.encode({'type':'collision', 'reason': reason}));
  }
  
  bool draw() {
    // Draw Point
    ctx.beginPath();
    ctx.fillStyle = color;
    ctx.arc(position.x, position.y, 3, 0, 2*PI);
    ctx.closePath();
    ctx.fill();
    
    // draw path & check for collision
    ctx.lineWidth = 4;
    ctx.strokeStyle = color;
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
    
    // Check all other playing curves if they collide with the current drawn path
    curves.where((Curve c) => (c != this && c.isPlaying)).forEach((Curve curve) {
      // Check if anyone is colliding with use
      //int start = new DateTime.now().millisecond;
      if(ctx.isPointInStroke(curve.position.x, curve.position.y)) {
        // If collision is detection always stop playing for that curve
        print('[${curve.name}] stopped playing.');
        curve.isPlaying = false;
        if(curve.isLocal) {
          curve.collision('stroke');
          print('[${curve.name}] Collsion with $name');
        }
      }
      //print((new DateTime.now().millisecond) - start);
    });
    
    return false;
  }
}

Future<bool> connectToServer(String localPlayerName, String gameId, String gamePassword) {
  Completer<bool> completer = new Completer();
  String url = "ws://" + window.location.hostname + ":1337/";
  webSocket = new WebSocket(url, gameId);
  webSocket.onOpen.first.then((Event ev) {
    print('websocket opened');
    webSocket.sendString(JSON.encode({'type': 'join_or_create_game', 'player': {'name': localPlayerName}, 'password': gamePassword}));
  });
  
  webSocket.onError.listen((Event ev) {
    print('websocket error');
  });
  
  webSocket.onClose.listen((CloseEvent ev) {
    print('webSocket closed. ${ev.code} ${ev.reason}');
  });
  
  webSocket.onMessage.listen((MessageEvent ev) {
    var json = JSON.decode(ev.data);
    switch(json['type']) {
      case "welcome" :
        completer.complete(true);
        isGameOwner = json['game_owner'];
        if(isGameOwner) {
          readyButton.text = 'Waiting for other players';
          readyButton.disabled = true;
        }
        break;
      case "join" :
        LIElement li = new LIElement();
        li.classes.add('player');
        li.appendHtml('''<span class="color ${json['player']['color']}"></span>
  <span class="ready"><i class="fa fa-'''+(json['player']['ready'] ? 'check' : 'times')+'''"></i></span>
  <span class="name">${json['player']['name']}</span>
  <span class="points">0</span>''');
        players[json['player']['name']] = json['player'];
        players[json['player']['name']]['li'] = li;
        playersList.append(li);
        break;
      case "leave" :
        LIElement li = players[json['player']['name']]['li'];
        if(li != null) {
          li.remove();
        }
        break;
      case "ready" :
        // Player is now ready
        players[json['player']['name']]['ready'] = true;
        LIElement li = players[json['player']['name']]['li'];
        li.querySelector('.ready i').classes.toggleAll(['fa-check', 'fa-times']);
        
        // Check if all other players are ready
        bool otherPlayersReady = true;
        players.forEach((String playerName, Map player) {
          if(playerName != localPlayerName && !player['ready']) {
            otherPlayersReady = false;
          }
        });
        
        if(otherPlayersReady) {
          readyButton.disabled = false;
          readyButton.text = 'Start game';
        }
        break;
      case "ready_abort" :
        // Player not ready anymore
        LIElement li = players[json['player']['name']]['li'];
        players[json['player']['name']]['ready'] = false;
        li.querySelector('.ready i').classes.toggleAll(['fa-check', 'fa-times']);
        
        if(isGameOwner) {
          readyButton.disabled = true;
          readyButton.text = 'Waiting for other players';
        }
        break;
      case "all_ready_start" :
        readyButton.disabled = true;
        readyButton.text = 'Game starts in 5';
        
        players.forEach((String playerName, Map data) {
          Curve curve = new Curve(playerName, data['color']);
          if(playerName == localPlayerName) {
            curve.isLocal = true;
          }
          players[playerName]['curve'] = curve;
          curves.add(curve);
        });
        break;
      case "stop" :
        print('game stopped');
        started = false;
        readyButton.classes.remove('ready');
        readyButton.classes.add('abort');
        webSocket.sendString(JSON.encode({'type': 'ready_abort'}));
        if(isGameOwner) {
          readyButton.disabled = true;
          readyButton.text = 'Waiting for other players';
        } else {
          readyButton.text = 'Not Ready';
        }
        break;
      case "collision" :
        Curve curve = (players[json['player']['name']]['curve'] as Curve);
        curve.isPlaying = false;
        print('[${curve.name}] Collision.');
        break;
      case "countdown" :
        readyButton.text = 'Game starts in ${json['time']}';
        break;
      case "positions" :
          (json['positions'] as Map).forEach((String playerName, Map info) {
            //print('position of player $playerName: $info');
            Curve curve = (players[playerName]['curve'] as Curve);
            curve.step(new Point(info['position']['x'], info['position']['y']));
            LIElement li = players[playerName]['li'];
            li.querySelector('.points').text = '${curve.points}';
          });
          
          if(!started) {
            draw();
          }
        break;
      case "start":
        started = true;
        start();
        break;
      default :
        print(json);
        break;
    }
  });
  
  return completer.future;
}

/*
void collisionDetector(SendPort sendPort) {
  var receivePort = new ReceivePort();
  sendPort.send(receivePort.sendPort);
  
  receivePort.listen((data) {
    print('collision received: $data');
  });
}
*/

void start() {
  window.requestAnimationFrame(gameLoop);
  // Curve myCurve = new Curve('red', myPlayerColor);
  // curves.add(myCurve);
  
  document.onKeyDown.listen((KeyboardEvent ev) {
    ev.preventDefault();
    switch(ev.keyCode) {
      case KeyCode.LEFT :
        webSocket.send(JSON.encode({'type': 'left_key_pressed'}));
        // myCurve.leftKeyPressed = true;
      break;
      case KeyCode.RIGHT :
        webSocket.send(JSON.encode({'type': 'right_key_pressed'}));
        // myCurve.rightKeyPressed = true;
        break;
    }
  });
  
  document.onKeyUp.listen((KeyboardEvent ev) {
    ev.preventDefault();
    switch(ev.keyCode) {
      case KeyCode.LEFT :
        webSocket.send(JSON.encode({'type': 'left_key_released'}));
        //myCurve.leftKeyPressed = false;
      break;
      case KeyCode.RIGHT :
        webSocket.send(JSON.encode({'type': 'right_key_released'}));
        // myCurve.rightKeyPressed = false;
        break;
    }
  });
}

void main() {
  /*
  Worker worker = new Worker('collision_detector.js');
  worker.onMessage.listen((MessageEvent ev) {
    print('${ev.data}');
  });
  */
  
  /*
  var receivePort = new ReceivePort();
  
  Isolate.spawnUri(new Uri.file('./collision_detector.dart'), [], receivePort.sendPort).then((Isolate isolate) {
    print('Isolate: $isolate');
    
    receivePort.listen((data) {
      print('main received: $data');
      
      if(data is SendPort) {
        SendPort sendPort = data;
        sendPort.send('test');
      }
    });
  });
  */
  
  CanvasElement canvas_icons = new CanvasElement(width: 20, height: 20);
  CanvasRenderingContext2D ctx_icons = canvas_icons.getContext('2d');
  ctx_icons.fillStyle = 'white';
  ctx_icons.font = 'FontAwesome';
  ctx_icons.fillText('ABC', 0, 0);
  String icon_bug = canvas_icons.toDataUrl('png', 100);
  document.body.appendHtml('<img src="$icon_bug">');
  
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');
  gameArea = new Rectangle(0, 0, canvas.width, canvas.height);
  readyButton = querySelector('#ready');
  playersList = querySelector('#players');
  
  querySelector('#join').onClick.listen((MouseEvent ev) {
    InputElement playerName = querySelector('#playername') as InputElement;
    InputElement gameId = querySelector('#gameid') as InputElement;
    InputElement gamePassword = querySelector('#gamepassword') as InputElement;
    
    if(playerName.value != "" && gameId.value !="") {
      connectToServer(playerName.value, gameId.value, gamePassword.value).then((status) {
        if(status) {
          querySelector('#overlay-login').style.display = 'none';
          querySelector('#game').style.display = 'flex';
        } else {
          print('error while connecting');
        }
      });
    }
  });
  
  readyButton.onClick.listen((MouseEvent ev) {
    isReady = !isReady;
    readyButton.classes.toggleAll(['ready', 'abort']);
    if(isReady) {
      webSocket.sendString(JSON.encode({'type': 'ready'}));
      readyButton.text = 'Ready';
    } else {
      webSocket.sendString(JSON.encode({'type': 'ready_abort'}));
      readyButton.text = 'Not Ready';
    }
  });
}

/**
 * Game Loop
 */

void gameLoop(num frame) {
  // int seconds = (frame ~/ 60);
  draw();
  
  if(started) {
    window.requestAnimationFrame(gameLoop);
  }
}

void draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
 
  // Render old path
  curves.forEach((Curve c) {
    ctx.save();
    c.draw();
    // c.step();
    ctx.restore();
  });
}