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
    switch(channel.protocol) {
      case 'game' :
        return new MessageProtocol(channel, messageFactory);
      case 'chat' :
        return new StringProtocol(channel);
      default :
        return new RawProtocol(channel);
    }
  }
}

/**
 * Game Message Interface
 */

abstract class CurveGameMessage {
  int get PAYLOAD_LENGTH;
  ByteData serialize();
}

/**
 * Handles serialization and instantiation of messages
 */

class CurveGameMessageFactory implements MessageFactory<CurveGameMessage> {
  CurveGameMessage unserialize(TypedData data) {
    Uint8List list = data.buffer.asUint8List();
    ByteData bytes = data.buffer.asByteData(1);
    switch(list.first) {
      case 0x01 :
        // return new PlayerNameMessage.unserialize();
        break;
    }
    // Get id from data and instantiate correct message
    // TODO(rh): Implementation
    return null;
  }

  TypedData serialize(CurveGameMessage message) {
    ByteData data = new ByteData(1 + message.PAYLOAD_LENGTH);
    data.setUint8(0, 0x00 /* MessageType */);
    data.buffer.asUint8List(1).setAll(1, message.serialize().buffer.asUint8List());
    return data;
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