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
  
  CurveGame game;
  
  String playerName;
  
  LoginScene(this.game) : super(querySelector('#scene-login')) {
    _joinButton = querySelector('#join');
    _joinButton.onClick.listen(_onJoinButtonClicked);
    disable();
  }
  
  /**
   * Join the given room.
   */
  
  void _onJoinButtonClicked(MouseEvent ev) {
    playerName = (querySelector('#playername') as InputElement).value;
    print('LoginName: $playerName');
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
    game.onPlayerJoin.listen(_playerJoined);
    game.onPlayerLeave.listen(_playerLeft);
    
    game.onJoinRoom.listen((Room room) {
      this.room = room;
      /*room.peers.forEach(_peerJoined);
      room.onJoin.listen(_peerJoined);
      room.onLeave.listen(_peerLeft);
      */
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
    _playersList.appendHtml('<li class="player" data-id="${player.id}"><span class="name">Player #${player.id}</span></li>');
  }
  
  void _playerLeft(Player player) {
    _playersList.querySelector('.player[data-id="${player.id}"]').remove();
  }
  
  void enable() {
    
  }
  
  void disable() {
    
  }
}

/**
 * Actual game
 */

class GameScene extends Scene {
  P2PGame game;
  
  GameScene(this.game) : super(querySelector('#scene-game')) {
    
  }
  
  void enable() {
  }
  
  void disable() {
    
  }
}