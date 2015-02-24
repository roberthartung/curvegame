// library curvegame;

import 'dart:html';
//import 'dart:math';
import 'dart:convert';
import 'dart:async';
//import "dart:isolate";
// import 'package:curvegame/DouglasPeucker.dart';
import 'package:curvegame/common.dart' as common;
import 'package:curvegame/client.dart' as client;

Future<bool> connectToServer(String localPlayerName, String gameId, String gamePassword) {
  Completer<bool> completer = new Completer();
  String url = "ws://" + window.location.hostname + ":${common.SERVER_PORT}";
  WebSocket webSocket = new WebSocket(url, gameId);
  
  webSocket.onMessage.first.then((MessageEvent ev) {
    var json = JSON.decode(ev.data);
    switch(json['type']) {
      case "welcome" :
        completer.complete(true);
        client.Game game = new client.Game(gameId, gamePassword, webSocket, json['game_owner']);
        break;
      default :
        print("Wrong first message received.");
        webSocket.close();
        break;
    }
  });
  
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
  
  return completer.future;
}

/**
 * Main function
 */

void main() {
  ButtonElement joinButton = querySelector('#join');
  joinButton.onClick.listen((MouseEvent ev) {
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

/*
void loadIcons() {
  icons.forEach((String name, dynamic data) {
    if(data is int) {
      ctx_icons.clearRect(0, 0, 30, 20);
      String text = new String.fromCharCode(data);
      TextMetrics metrics = ctx_icons.measureText(text);
      // print('metrics: ${metrics.width} ${metrics.actualBoundingBoxAscent} ${metrics.actualBoundingBoxDescent}');
      ctx_icons.fillText(text, (30-metrics.width)/2, 0);
      String iconUrl = canvas_icons.toDataUrl('png', 100);
      icons[name] = iconUrl;
      querySelector('#login').appendHtml('<img src="$iconUrl">');
    }
  });
}
*/

/*
 Worker worker = new Worker('collision_detector.js');
 worker.onMessage.listen((MessageEvent ev) {
   print('${ev.data}');
 });
 
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
 /*
 LinkElement link = querySelector('#font');
 link.onLoad.listen((_) {
   loadIcons();
 });
 
 loadIcons();
 */