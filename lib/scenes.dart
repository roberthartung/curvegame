part of curvegame;

/**
 * Basic Scene
 */

abstract class Scene {
  Element rootElement;
  
  Scene(this.rootElement) {
    rootElement.classes.add('scene');
    rootElement.attributes['hidden'] = '';
  }
  
  void _show() {
    rootElement.attributes.remove("hidden");
  }
  
  void enable();
  
  void disable();
}

/**
 * Login Scene
 */

class LoginScene extends Scene {
  ButtonElement _joinButton;
  
  P2PGame game;
  
  LoginScene(this.game) : super(querySelector('#scene-login')) {
    _joinButton = querySelector('#join');
    _joinButton.onClick.listen(_onJoinButtonClicked);
    disable();
  }
  
  /**
   * Join the given room.
   */
  
  void _onJoinButtonClicked(MouseEvent ev) {
    // TODO(rh): Names are not included in webrtc_utils.game library! Realize this as a game specific message
    // querySelector('#playername') as InputElement).value
    game.join((querySelector('#gameid') as InputElement).value, (querySelector('#gamepassword') as InputElement).value);
  }
  
  void enable() {
    _joinButton.disabled = false;
  }
  
  void disable() {
    _joinButton.disabled = true;
  }
}

/**
 * Displays the room, its players and handles ready state and chat
 */

class RoomScene extends Scene {
  P2PGame game;
  
  Room room;
  
  UListElement _playersList;
  
  RoomScene(this.game) : super(querySelector('#scene-room')) {
    game.onJoinRoom.listen((Room room) {
      this.room = room;
      room.peers.forEach(_peerJoined);
      room.onJoin.listen(_peerJoined);
      room.onLeave.listen(_peerLeft);
    });
    
    game.onPlayerJoin.listen((Player player) {
      _playerJoined(player);
      if(player is RemotePlayer) {
        print('RemotePlayer $player joined.');
        // TODO(rh): 
      } else {
        // LocalPlayer joined
      }
    });
    
    _playersList = rootElement.querySelector('#players');
    
    InputElement messageInput = rootElement.querySelector('#message');
    
    messageInput.onKeyDown.listen((KeyboardEvent ev) {
      if(ev.keyCode == KeyCode.ENTER) {
        ev.preventDefault();
        print('ChatMessage: ${messageInput.value}');
        // Send Message to other peers
        // Use Peer to Player Map?
        room.peers.forEach((Peer peer) {
          // TODO(rh): Get StringProtocol from Player? (Chat) and send ChatMessage
        });
        messageInput.value = '';
      }
    });
  }
  
  void _playerJoined(Player player) {
    
  }
  
  void _peerJoined(Peer peer) {
    print('Peer $peer joined room $room');
    _playersList.appendHtml('<li class="player" data-id="${peer.id}"><span class="name">Player #${peer.id}</span></li>');
  }
  
  void _peerLeft(Peer peer) {
    print('Peer $peer left room $room');
    _playersList.querySelector('.player[data-id="${peer.id}"]').remove();
  }
  
  void enable() {
    
  }
  
  void disable() {
    
  }
}

class GameScene extends Scene {
  P2PGame game;
  
  GameScene(this.game) : super(querySelector('#scene-game')) {
    
  }
  
  void enable() {
  }
  
  void disable() {
    
  }
}