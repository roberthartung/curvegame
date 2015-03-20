part of curvegame;

/**
 * The Game :-)
 * TODO(rh): Separate UI from Game
 */

/*
class CurveGame extends P2PGame {
  ButtonElement _readyButton;
  
  UListElement _playersList;
  
  GameProtocolProvider _protocolProvider;
  
  final List<Player> players = [];
  
  LocalPlayer localPlayer = null;
  
  /**
   * Player object of the current game owner
   */
  
  Player owner;
  
  /**
   * Indicates if the local player is the game owner
   */
  
  bool _gameOwner = false;
  bool get isOwner => _gameOwner;
  
  /**
   * Constructor
   */
  
  CurveGame() {
    _readyButton = querySelector('#ready');
    _readyButton.disabled = true;
    _playersList = querySelector('#players');
    _protocolProvider = new GameProtocolProvider(this);
    addProtocolProvider('game', _protocolProvider);
    
    onConnect.listen((final int id) {
      print('Local ID: $id');
    });
    
    _readyButton.onClick.listen(_onReadyButtonClicked);
  }
  
  void _onRoomJoined(final Room room) {
    querySelector('#overlay-login').style.display = 'none';
    querySelector('#game').style.display = 'flex';
    if(room.peers.length == 0) {
      _gameOwner = true;
    } else {
      // Enable ReadyButton if we're not the leader
      _readyButton.disabled = false;
    }
    room.peers.forEach(_onPeerJoined);
    room.onJoin.listen(_onPeerJoined);
    localPlayer = new LocalPlayer(this, id);
    // TODO(rh): EventListeners // Abstraction layer for mobile devices?
    _appendPlayer(localPlayer);
  }
  
  /**
   * Local player clicked the ready button
   */
  
  void _onReadyButtonClicked(MouseEvent ev) {
    localPlayer.setReady(!localPlayer.isReady);
  }
}
*/

class CurveGameMessageFactory implements GameMessageFactory {
  GameMessage unserialize(TypedData data) {
    // TODO(rh): Implementation
    return null;
  }
}

class CurveGame extends P2PGame {
  RoomScene _roomScene;
  LoginScene _loginScene;
  GameScene _gameScene;
  
  /**
   * List of players
   */
  
  final List<Player> players = [];
  
  /**
   * List of Peers, mapped to remote players
   */
  
  final Map<Peer, RemotePlayer> peerToPlayer = {};
  
  // TODO(rh): Pass ProtocolFactory/ProtocolProvider and MessageFactory to P2PGame
  CurveGame() : super("ws://" + window.location.hostname + ":28080", rtcConfiguration, new GameProtocolProvider(), new CurveGameMessageFactory()) {
    // When we're connected to the signaling server, enable login
    onConnect.listen((_) {
      _loginScene.enable();
    });
    
    onJoinRoom.listen(_onRoomJoined);
    
    // Create scenes
    _loginScene = new LoginScene(this);
    _roomScene = new RoomScene(this);
    _gameScene = new GameScene(this);
    // Set current scene
    showScene(_loginScene);
  }
  
  Scene _currentScene = null;
  
  void showScene(Scene s) {
    _currentScene = s;
    s._show();
  }
  
  /**
   * A new remote peer joined: Initialize channels if needed
   */
  
  void _onPeerJoined(final Peer peer) {
    Player player = new RemotePlayer(this, peer);
    peerToPlayer[peer] = player;
    _appendPlayer(player);
    // If local id is smaller then remote peer id, initialize channels
    if(id < peer.id) {
      peer.createChannel('chat', {'protocol': 'string'});
      peer.createChannel('game', {'protocol': 'game'});
    }
  }
  
  /**
   * New Player joined - append player to all lists
   */
  
  void _appendPlayer(Player player) {
    //_playersList.append(player.li);
    players.add(player);
    /*
    if(owner == null) {
      owner = player;
    } else if(owner.id > player.id) {
      // TODO(rh): Remove current leader
      owner = player;
    }
    */
  }
  
  void _onRoomJoined(final Room room) {
    showScene(_roomScene);
  }
}