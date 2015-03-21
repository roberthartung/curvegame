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
  Object serialize();
}

/**
 * Handles serialization and instantiation of messages
 */

class CurveGameMessageFactory implements MessageFactory<CurveGameMessage> {
  /**
   * Unserializes data from a string (JSON) to a message
   */
  
  CurveGameMessage unserialize(dynamic message) {
    Object data = JSON.decode(message);
    if(data is Map) {
      if(data.containsKey('PlayerNameMessage')) {
        return new PlayerNameMessage.unserialize(data['PlayerNameMessage']);
      }
    } else {
      throw "Unable to decode CurveGameMessage.";
    }
    return null;
  }
  
  /**
   * Serialized a message to a string (via json)
   */

  dynamic serialize(CurveGameMessage message) {
    return JSON.encode({message.runtimeType.toString(): message.serialize()});
  }
}

class PlayerNameMessage implements CurveGameMessage {
  final String name;
  
  PlayerNameMessage(this.name);
  
  PlayerNameMessage.unserialize(this.name);
  
  Object serialize() {
    return name;
  }
}

/**
 * Player changed ready status
 */

class ReadyMessage implements CurveGameMessage {
  final bool ready;
  
  /**
   * Local constructor
   */
  
  ReadyMessage(ReadyPlayer player)
    : ready = player.isReady;
  
  /**
   * Remote Constructor
   */
  
  ReadyMessage.unserialize(this.ready);
  
  bool serialize() {
    return ready;
  }
}

class PingMessage implements CurveGameMessage {
  /**
   * Local constructor
   */
  
  PingMessage();
  
  /**
   * Remote Constructor
   */
  
  PingMessage.unserialize(Object data);
  
  dynamic serialize() {
    return null;
  }
}

/**
 * TODO(rh): Do we need two different messages?
 */

class PongMessage extends CurveGameMessage {
  /**
   * Local constructor
   */
  
  PongMessage();
  
  /**
   * Remote Constructor
   */
  
  PongMessage.unserialize(Object data);
  
  dynamic serialize() {
    return null;
  }
}