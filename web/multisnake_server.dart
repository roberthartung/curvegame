library curvegame_server;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // Point

part 'game.dart';
part 'player.dart';

void main() {
  ServerSocket.bind("0.0.0.0", 1337).then((ServerSocket serverSocket) {
    HttpServer httpServer = new HttpServer.listenOn(serverSocket);
    Map<String, Game> games = {};
    print('Server running');
    httpServer.listen((HttpRequest request) {
      print('new HttpRequest');
      WebSocketTransformer.upgrade(request, protocolSelector: (List<String> protocols) {
        return protocols[0];
      }).then((WebSocket socket) {
        //print('new WebSocket');
        String gameId = socket.protocol;
        Game game = games[gameId];
        Stream dataStream = socket.asBroadcastStream();
        dataStream.first.then((json) {
          var data = JSON.decode(json);
          switch(data['type']) {
            case 'join_or_create_game' :
              if(game == null) {
                game = new Game(gameId, data['password']);
                game.onEmpty.first.then((_) {
                  print('game $gameId deleted.');
                  games.remove(gameId);
                });
                games[gameId] = game;
              } else if(game.password != data['password']) {
                // If password is not correct, close socket
                //socket.add(JSON.encode({'type': 'error', 'error': 'wrong_password'}));
                socket.close(WebSocketStatus.PROTOCOL_ERROR, 'wrong_password');
                print('socket closed due to wrong password');
                return;
              }
              Player player = new Player(game, dataStream, socket, data['player']['name']);
              if(!game.addPlayer(player)) {
                socket.close(WebSocketStatus.PROTOCOL_ERROR, 'player_with_name_exists_in_game');
              }
              break;
          }
        });
      });
    });
  });
}
