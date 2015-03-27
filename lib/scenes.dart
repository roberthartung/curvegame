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
  /**
   * The game instance this scene belongs to
   */
  
  final CurveGame game;
  
  /**
   * The last room the player joined
   */
  
  //Room room;
  
  /**
   * List of players in the "lobby"
   */
  
  UListElement _playersList;
  
  /**
   * List of players in the "lobby"
   */
  
  UListElement _messagesList;
  
  /**
   * Ready Button
   */
  
  ButtonElement _readyButton;
  
  /**
   * Ready count
   */
  
  int _playersReadyCount = 0;
  
  /**
   * Constructor
   */
  
  RoomScene(this.game) : super(querySelector('#scene-room')) {
    _playersList = rootElement.querySelector('#players');
    _messagesList = rootElement.querySelector('#messages');
    InputElement messageInput = rootElement.querySelector('#message');
    _readyButton = rootElement.querySelector('#ready');
    
    // Setup listeners
    game.onPlayerJoin.listen(_playerJoined);
    game.onPlayerLeave.listen(_playerLeft);
    //game.onJoinRoom.listen((Room room) => (this.room = room));
    _readyButton.onClick.listen((MouseEvent ev) {
      if(game.isOwner) {
        _readyButton.disabled = true;
        // TODO(rh): re-implement
        // game.startCountdown();
      } else {
        game.localPlayer.toggleReady();
      }
    });
      
    messageInput.onKeyDown.listen((KeyboardEvent ev) {
      if(ev.keyCode == KeyCode.ENTER) {
        ev.preventDefault();
        _appendMessage(game.localPlayer, messageInput.value);
        List<Future> futures = [];
        game.players.where((Player otherPlayer) => (otherPlayer is RemoteCurvePlayer)).forEach((RemoteCurvePlayer remotePlayer) {
          futures.add(remotePlayer.getChatChannel().then((StringProtocol protocol) {
            protocol.send(messageInput.value);
          }));
        });
        
        // Wait until all messages are send, then clear the input
        Future.wait(futures).then((_) => messageInput.value = '');
      }
    });
    
    game.onGameOwnerChanged.listen((Player player) {
      print('[$this] Game owner changed to $player ${player.isLocal} ${game.isOwner}');
      if(player.isLocal) {
        // Local player is now 
        _updateReadyButton();
      }
    });
  }
  
  /**
   * Appends a chat message to the room
   */
  
  void _appendMessage(NamedPlayer player, String message) {
    _messagesList.appendHtml('<li class="message"><span class="player">${player.name}:</span> ${message}</li>');
  }
  
  /**
   * Called for every player that joined the game
   */
  
  void _playerJoined(Player player) {
    _playersList.appendHtml('<li class="player" data-id="${player.id}"><span class="name">Player #${player.id}</span></li>');
    LIElement li = _playersList.lastChild;
    (player as ReadyPlayer).onReadyStateChanged.listen((bool readyState) {
      li.classes.toggle('ready', readyState);
    });
    
    // Update readyButton and enable it in case it is still disabled
    if(game.isOwner) {
      _updateReadyButton();
    }
    
    if(player is RemoteCurvePlayer) {
      // Setup Chat
      player.getChatChannel().then((StringProtocol chat) {
        chat.onMessage.listen((String message) => _appendMessage(player, message));
      });
      // Another player joined and we're the owner
      if(game.isOwner) {
        // Whenever the player changes his ready state
        player.onReadyStateChanged.listen(_remotePlayerReadyStateChange);
      }
    }
  }
  
  /**
   * A Remote player changed the ready state
   */
  
  void _remotePlayerReadyStateChange(bool isReady) {
    if(isReady) {
      _playersReadyCount++;
    } else {
      _playersReadyCount--;
    }
    _updateReadyButton();
  }
  
  /**
   * Update ready button
   */
  
  void _updateReadyButton() {
    int total = game.players.length - 1;
    
    if(total == 0) {
      _readyButton.text = 'No other players';
      _readyButton.disabled = true;
      return;
    }
    
    if(_playersReadyCount == total) {
      _readyButton.text = 'Start game';
      _readyButton.disabled = false;
      // Local Player can now click as well
    } else {
      _readyButton.text = 'Waiting for other players (${_playersReadyCount}/$total)';
      _readyButton.disabled = true;
    }
  }
  
  /**
   * Event handler for when a player leaves a room
   */
  
  void _playerLeft(Player player) {
    _playersList.querySelector('.player[data-id="${player.id}"]').remove();
    
    if(player is ReadyPlayer) {
      if((player as ReadyPlayer).isReady) {
        _playersReadyCount--;
        _updateReadyButton();
      }
    }
    
    // TODO(rh): StreamSubscription cleanup
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
  CurveGame game;
  
  GameScene(this.game) : super(querySelector('#scene-game')) {
    
  }
  
  void enable() {
    
  }
  
  void disable() {
    
  }
}