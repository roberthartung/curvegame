part of curvegame;

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
 * Displays the room, its players and handles ready state
 */

class RoomScene extends Scene {
  P2PGame game;
  
  Room room;
  
  RoomScene(this.game) : super(querySelector('#scene-room')) {
    game.onJoinRoom.listen((Room room) {
      this.room = room;
      room.peers.forEach(_peerJoined);
    });
  }
  
  void _peerJoined(Peer peer) {
    
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