library curvegame_server;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:curvegame/common.dart' as common;
import 'package:curvegame/server.dart' as server;

Map<String, server.Game> games = {};

void main() {
  // Bind server
  ServerSocket.bind("0.0.0.0", common.SERVER_PORT).then((ServerSocket serverSocket) {
    HttpServer httpServer = new HttpServer.listenOn(serverSocket);
    print('Server running');
    httpServer.listen(onHttpRequest);
  });
}

void onHttpRequest(HttpRequest request) {
  WebSocketTransformer.upgrade(request, protocolSelector: (List<String> protocols) {
    return protocols[0];
  }).then(onWebSocket);
}

void onWebSocket(WebSocket socket) {
  // We use the websocket protocol to identify the game
  String gameId = socket.protocol;
  server.Game game = games[gameId];
  Stream dataStream = socket.asBroadcastStream();
  // Wait for first message (type join_or_create_game)
  dataStream.first.then((json) {
    var data = JSON.decode(json);
    switch(data['type']) {
      case 'join_or_create_game' :
        if(game == null) {
          game = new server.Game(gameId, data['password']);
          game.onEmpty.first.then((_) {
            print('game $gameId deleted.');
            games.remove(gameId);
          });
          games[gameId] = game;
        } else if(game.password != data['password']) {
          // If password is not correct, close socket
          socket.close(WebSocketStatus.PROTOCOL_ERROR, 'wrong_password');
          print('socket closed due to wrong password');
          return;
        }
        
        server.Player player = new server.Player(data['player']['name'], game, dataStream, socket);
        if(!game.addPlayer(player)) {
          socket.close(WebSocketStatus.PROTOCOL_ERROR, 'player_with_name_exists_in_game');
        }
        break;
    }
  });
}