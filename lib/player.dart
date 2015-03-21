part of curvegame;

class LocalCurvePlayer extends LocalPlayer with ReadyPlayer {
  final String name;
  
  PlayerNameMessage _playerNameMessage;
  
  LocalCurvePlayer(P2PGame game, int id, this.name) : super(game, id) {
    _playerNameMessage = new PlayerNameMessage(name);
    /*
    game.onPlayerJoin.where((Player p) => p is RemoteCurvePlayer).listen((RemoteCurvePlayer player) {
      print('RemoteCurvePlayer $player joined');
      player.getGameChannel().then((MessageProtocol protocol) {
        print('GameProtocol is ready: $protocol');
        protocol.send(_playerNameMessage);
      });
    });
    */
  }
  
  // Implement local listeners for events (e.g. Keyboard, Mouse, ...)
  // Implement sending local events to others
}

class RemoteCurvePlayer extends RemotePlayer with ReadyPlayer {
  MessageProtocol gameChannel = null;
  
  StringProtocol chatChannel = null;
  
  Completer<MessageProtocol> _gameChannelCompleter = null;
  
  Completer<StringProtocol> _chatChannelCompleter = null;
  
  String get name => _name;
  String _name;
  
  RemoteCurvePlayer(P2PGame game, Peer peer) : super(game, peer) {
    peer.onProtocol.listen((DataChannelProtocol protocol) {
      // TODO(rh): Handle onClose
      switch(protocol.channel.label) {
        case 'game' :
          if(protocol is MessageProtocol) {
            gameChannel = protocol;
            
            if(_gameChannelCompleter != null) {
              _gameChannelCompleter.complete(protocol);
            }
          }
          break;
        case 'chat' :
          if(protocol is StringProtocol) {
            chatChannel = protocol;
            if(_chatChannelCompleter != null) {
              _chatChannelCompleter.complete(protocol);
            }
          }
          break;
      }
    });
    
    // Wait for game channel
    getGameChannel().then((_) {
      gameChannel.onMessage.listen((CurveGameMessage message) {
        if(message is PlayerNameMessage) {
          _name = message.name;
          print('Player name received: $name');
        } else {
          print('[$this] CurveGameMessage: $message');
        }
      });
      print('[$this] gameChannel: $gameChannel');
    });
  }
  
  /**
   * Returns a future that is ready when the chat channel is opened
   */
  
  Future<StringProtocol> getChatChannel() {
    if(chatChannel != null) {
      return new Future.value(chatChannel);
    }
    
    if(_chatChannelCompleter == null) {
      _chatChannelCompleter = new Completer();
    }
    
    return _chatChannelCompleter.future;
  }
  
  /**
   * Returns a future that is ready when the game channel is opened
   */
  
  Future<MessageProtocol> getGameChannel() {
    if(gameChannel != null) {
      return new Future.value(gameChannel);
    }
    
    if(_gameChannelCompleter == null) {
      _gameChannelCompleter = new Completer();
    }
    
    return _gameChannelCompleter.future;
  }
}