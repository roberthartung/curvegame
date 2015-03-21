part of curvegame;

class LocalCurvePlayer extends LocalPlayer with ReadyPlayer {
  LocalCurvePlayer(P2PGame game, int id) : super(game, id);
  
  // Implement local listeners for events (e.g. Keyboard, Mouse, ...)
  // Implement sending local events to others
}

class RemoteCurvePlayer extends RemotePlayer with ReadyPlayer {
  /*
  Stream<MessageProtocol> get onChatOpened => peer.onProtocol.where((DataChannelProtocol protocol) => protocol is MessageProtocol && protocol.channel.label == 'game');
  
  Stream<MessageProtocol> get onChatOpened => peer.onProtocol.where((DataChannelProtocol protocol) => protocol is MessageProtocol && protocol.channel.label == 'game');
  */
  
  MessageProtocol gameChannel;
  
  StringProtocol chatChannel;
  
  RemoteCurvePlayer(P2PGame game, Peer peer) : super(game, peer) {
    peer.onProtocol.listen((DataChannelProtocol protocol) {
      switch(protocol.channel.label) {
        case 'game' :
          if(protocol is MessageProtocol) {
            gameChannel = protocol;
          }
          break;
        case 'chat' :
          if(protocol is StringProtocol) {
            chatChannel = protocol;
          }
          break;
      }
      print('Protocol $protocol opened.');
    });
  }
  
  Future<MessageProtocol> getChatChannel() {
    Completer completer;
    
    return completer.future;
  }
  
  Future<MessageProtocol> getGameChannel() {
    Completer completer;
    
    return completer.future;
  }
  
  
  // Wait for 
  // Implement parsing of remote messages
}