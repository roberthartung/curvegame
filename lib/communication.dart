part of curvegame;

/**
 * Provides an instance of [GameProtocol] and maps the peer to the [RemotePlayer]
 */

class GameProtocolProvider implements ProtocolProvider {
  final CurveGame game;
  
  GameProtocolProvider(this.game);
  
  DataChannelProtocol provide(Peer peer, RtcDataChannel channel) {
    // .peerToPlayer[peer]
    return new GameProtocol(game, channel);
  }
}

/**
 * Player changed ready status
 */

class ReadyMessage extends GameMessage {
  static int MESSAGE_ID = 0x01;
  
  final bool ready;
  
  /**
   * Local constructor
   */
  
  ReadyMessage(ReadyPlayer player)
    : ready = player.isReady;
  
  /**
   * Remote Constructor
   */
  
  ReadyMessage._fromByteData(ByteData data)
    : ready = (data.getUint8(1) == 0xFF);
  
  TypedData serialize() {
    ByteData data = new ByteData(2);
    data.setUint8(0, MESSAGE_ID);
    data.setUint8(1, ready ? 0xFF : 0x00);
    return data;
  }
}

class PingMessage extends GameMessage {
  static const int MESSAGE_ID = 0x02;
  
  //final int time;
  
  /**
   * Local constructor
   */
  
  PingMessage() /*: time = (new DateTime.now().millisecondsSinceEpoch)*/;
  
  /**
   * Remote Constructor
   */
  
  PingMessage._fromByteData(ByteData data)/*
    : time = (data.getInt64(1))*/;
  
  TypedData serialize() {
    ByteData data = new ByteData(1/*+8*/);
    data.setUint8(0, MESSAGE_ID);
    //data.setInt64(1, time);
    return data;
  }
}

/**
 * TODO(rh): Do we need two different messages?
 */

class PongMessage extends GameMessage {
  static const int MESSAGE_ID = 0x03;
  
  /**
   * Local constructor
   */
  
  PongMessage();
  
  /**
   * Remote Constructor
   */
  
  PongMessage._fromByteData(ByteData data);
  
  TypedData serialize() {
    ByteData data = new ByteData(1);
    data.setUint8(0, MESSAGE_ID);
    return data;
  }
}