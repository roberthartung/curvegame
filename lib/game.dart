part of curvegame;

class CurveGame extends P2PGame {
  RoomScene _roomScene;
  LoginScene _loginScene;
  GameScene _gameScene;
  
  // TODO(rh): Pass ProtocolFactory/ProtocolProvider and MessageFactory to P2PGame
  CurveGame() : super("ws://" + window.location.hostname + ":28080", rtcConfiguration) {
    setProtocolProvider(new CurveGameProtocolProvider(new CurveGameMessageFactory()));
    // When we're connected to the signaling server, enable login
    onConnect.listen((_) {
      _loginScene.enable();
    });
    // Create scenes
    _loginScene = new LoginScene(this);
    _roomScene = new RoomScene(this);
    _gameScene = new GameScene(this);

    onJoinRoom.listen(_onRoomJoined);
    onPlayerJoin.listen(_onPlayerJoined);
    // Set current scene
    showScene(_loginScene);
  }

  Scene _currentScene = null;

  void showScene(Scene s) {
    _currentScene = s;
    s._show();
  }
  
  void _onRoomJoined(final Room room) {
    showScene(_roomScene);
  }
  
  void _onPlayerJoined(Player player) {
    if(player is RemotePlayer) {
      // Create Channels if local id is smaller than remote peer id
      if(id < player.peer.id) {
        player.peer.createChannel('game', {'protocol': 'game'});
        player.peer.createChannel('chat', {'protocol': 'chat'});
      }
    }
  }
  
  @override
  LocalPlayer createLocalPlayer(int id) {
    return new LocalCurvePlayer(this, id);
  }
  
  @override
  RemotePlayer createRemotePlayer(Peer peer) {
    return new RemoteCurvePlayer(this, peer);
  }
}
