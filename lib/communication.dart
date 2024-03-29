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
      // Unserialize messages
      if(data.containsKey('PlayerNameMessage')) {
        return new PlayerNameMessage.unserialize(data['PlayerNameMessage']);
      } else if(data.containsKey('ReadyMessage')) {
        return new ReadyMessage.unserialize(data['ReadyMessage']);
      } else if(data.containsKey('PingMessage')) {
        return new PingMessage.unserialize(data['PingMessage']);
      } else if(data.containsKey('PongMessage')) {
        return new PongMessage.unserialize(data['PongMessage']);
      } else if(data.containsKey('StartGameMessage')) {
        return new StartGameMessage.unserialize(data['StartGameMessage']);
      } else if(data.containsKey('TickSyncMessage')) {
        return new TickSyncMessage.unserialize(data['TickSyncMessage']);
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

/**
 * Transfer the name's player
 */

class PlayerNameMessage implements CurveGameMessage {
  final String name;
  
  PlayerNameMessage(this.name);
  
  PlayerNameMessage.unserialize(this.name);
  
  Object serialize() {
    return name;
  }
}

/**
 * Starts the game and the countdown
 */

class StartGameMessage implements CurveGameMessage {
  /**
   * Local constructor
   */
  
  StartGameMessage();
  
  /**
   * Remote Constructor
   */
  
  StartGameMessage.unserialize(Object data);
  
  dynamic serialize() {
    return null;
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

class PongMessage implements CurveGameMessage {
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

/**
 *
 */

class TickSyncMessage implements CurveGameMessage {
  final int tick;
  
  /**
   * Local constructor
   */
  
  TickSyncMessage(this.tick);
  
  /**
   * Remote Constructor
   */
  
  TickSyncMessage.unserialize(this.tick);
  
  dynamic serialize() {
    return tick;
  }
}