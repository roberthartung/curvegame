part of curvegame;

class CurveGameRoom extends SynchronizedGameRoom {
  CurveGameRoom(CurveGame game, Room room) : super(game, room) {
    
  }
  
  @override
  LocalPlayer createLocalPlayer(int id) {
    return new LocalCurvePlayer(this, id, _loginScene.playerName);
  }
  
  @override
  RemotePlayer createRemotePlayer(Peer peer) {
    return new RemoteCurvePlayer(this, peer);
  }
}
