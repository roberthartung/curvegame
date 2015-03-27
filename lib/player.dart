part of curvegame;

/**
 * Common player logic
 */

abstract class CurveGamePlayer {
  bool _isAlive = true;
  
  bool get isAlive => _isAlive;
  
  bool get isLocal;
  
  CurveGameRoom get room;
  
  /**
   * Concrete implementation of the [NamedPlayer] mixin
   */
  
  String get name => _name;
  String _name;
  
  Point position;
  
  Vector direction;
  
  PathSegment currentSegment;
  
  List<PathSegment> pathSegments = [];
  
  num distance = 0;
  
  void tick(int count) {
    /*
    if(isLocal) {
      if(count % 25 == 0) {
        // Send tick count to others
        game.remotePlayers.forEach((RemoteCurvePlayer player) {
          player.gameChannel.send(new TickSyncMessage(count));
        });
      }
    }
    */
  }
}

/**
 * The local player class
 */

class LocalCurvePlayer extends SynchronizedLocalPlayer<CurveGameRoom> with CurveGamePlayer, NamedPlayer, ReadyPlayer, LocalReadyPlayer {
  /**
   * The game internal message that exchanges this [Player]'s name with others
   */
  
  PlayerNameMessage _playerNameMessage;
  
  /**
   * Constructor
   */
  
  LocalCurvePlayer(GameRoom room, int id, String name) : super(room, id) {
    _name = name;
    _playerNameMessage = new PlayerNameMessage(name);
    // Send local name to other players
    room.onPlayerJoin.where((Player p) => p is RemoteCurvePlayer).listen((RemoteCurvePlayer player) {
      player.getGameChannel().then((MessageProtocol protocol) {
        protocol.send(_playerNameMessage);
      });
    });
  }
  
  // Implement local listeners for events (e.g. Keyboard, Mouse, ...)
  // Implement sending local events to others
}

/**
 * The remote player class
 */

class RemoteCurvePlayer extends SynchronizedRemotePlayer<CurveGameRoom> with CurveGamePlayer, NamedPlayer, ReadyPlayer, RemoteReadyPlayer, PingablePlayer {
  /**
   * A [RtcDataChannel] using a [MessageProtocol] to exchange game information
   */
  
  MessageProtocol gameChannel = null;
  
  /**
   * A [RtcDataChannel] using a [StringProtocol] to exchance messages
   */
  
  StringProtocol chatChannel = null;
  
  /**
   * Internal completer used to notify about the game channel
   */
  
  Completer<MessageProtocol> _gameChannelCompleter = null;
  
  /**
   * Internal completer used to notify about the chat channel
   */
  
  Completer<StringProtocol> _chatChannelCompleter = null;
  
  /**
   * Constructor
   */
  
  RemoteCurvePlayer(CurveGameRoom room, ProtocolPeer peer) : super(room, peer) {
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
    
    // Wait for game channel to be ready -> setup message listener and start ping timer
    getGameChannel().then((_) {
      gameChannel.onMessage.listen(_onGameMessage);
      startPingTimer();
    });
  }
  
  /**
   * Called for every game message
   */
  
  void _onGameMessage(CurveGameMessage message) {
    if(message is PlayerNameMessage) {
      _name = message.name;
      // TODO(rh): Fire Event
      print('Player name received: $name');
    } else if(message is ReadyMessage) {
      setReady(message.ready);
    } else if(message is PingMessage) {
      pingReceived();
    } else if(message is PongMessage) {
      pongReceived();
    } else if(message is StartGameMessage) {
      // TODO(rh): re-implement
      // game.startCountdown();
    } else {
      print('[$this] CurveGameMessage: $message');
    }
  }
  
  @override
  sendLocalReadyStatus(LocalCurvePlayer player) {
    getGameChannel().then((_) {
      gameChannel.send(new ReadyMessage(player));
    });
  }
  
  @override
  void sendPing() {
    getGameChannel().then((_) {
      gameChannel.send(new PingMessage());
    });
  }
  
  @override
  void sendPong() {
    getGameChannel().then((_) {
      gameChannel.send(new PongMessage());
    });
  }
  
  /**
   * Returns a future that is ready when the chat channel is opened and ready to use
   */
  
  Future<StringProtocol> getChatChannel() {
    // If the channel is already opened we can completely immedeately
    if(chatChannel != null) {
      return new Future.value(chatChannel);
    }
    
    if(_chatChannelCompleter == null) {
      _chatChannelCompleter = new Completer();
    }
    
    return _chatChannelCompleter.future;
  }
  
  /**
   * Returns a future that is ready when the game channel is opened and ready to use
   */
  
  Future<MessageProtocol> getGameChannel() {
    // If the channel is already opened we can completely immedeately
    if(gameChannel != null) {
      return new Future.value(gameChannel);
    }
    
    if(_gameChannelCompleter == null) {
      _gameChannelCompleter = new Completer();
    }
    
    return _gameChannelCompleter.future;
  }
}