part of curvegame;

class LocalCurvePlayer extends LocalPlayer with ReadyPlayer {
  LocalCurvePlayer(P2PGame game, int id) : super(game, id);
  
  // Implement local listeners for events (e.g. Keyboard, Mouse, ...)
  // Implement sending local events to others
}

class RemoteCurvePlayer extends RemotePlayer with ReadyPlayer {
  RemoteCurvePlayer(P2PGame game, Peer peer) : super(game, peer);
  
  // Wait for 
  // Implement parsing of remote messages
}