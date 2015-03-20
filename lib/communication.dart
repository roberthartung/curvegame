/**
 * Communication part of the curvegame
 * Defines messages and protocols
 */

part of curvegame;

/**
 * Provides an instance of [GameProtocol] and maps the peer to the [RemotePlayer]
 */

class CurveGameProtocolProvider implements ProtocolProvider {
  final MessageFactory messageFactory;
  
  CurveGameProtocolProvider(this.messageFactory);
  
  DataChannelProtocol provide(Peer peer, RtcDataChannel channel) {
    // .peerToPlayer[peer]
    // Peer peer, 
    return new MessageProtocol(channel, messageFactory);
  }
}

/**
 * Player changed ready status
 */

class ReadyMessage extends CurveGameMessage {
  final int PAYLOAD_LENGTH = 1;
  
  final bool ready;
  
  /**
   * Local constructor
   */
  
  ReadyMessage(ReadyPlayer player)
    : ready = player.isReady;
  
  /**
   * Remote Constructor
   */
  
  ReadyMessage.unserialize(ByteData data)
    : ready = (data.getUint8(1) == 0xFF);
  
  TypedData serialize() {
    ByteData data = new ByteData(1);
    data.setUint8(1, ready ? 0xFF : 0x00);
    return data;
  }
}

class PingMessage extends CurveGameMessage {
  final int PAYLOAD_LENGTH = 0;
  
  /**
   * Local constructor
   */
  
  PingMessage();
  
  /**
   * Remote Constructor
   */
  
  PingMessage.unserialize(ByteData data);
  
  TypedData serialize() {
    return null;
  }
}

/**
 * TODO(rh): Do we need two different messages?
 */

class PongMessage extends CurveGameMessage {
  final int PAYLOAD_LENGTH = 0;
  
  /**
   * Local constructor
   */
  
  PongMessage();
  
  /**
   * Remote Constructor
   */
  
  PongMessage.unserialize(ByteData data);
  
  TypedData serialize() {
    return null;
  }
}