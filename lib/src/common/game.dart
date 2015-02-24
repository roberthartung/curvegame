part of curvegame.common;

abstract class Game<P> {
  String gameId;
  
  List<P> players;
  
  String password = null;
  
  int width = 800;
    
  int height = 800;
  
  Game(this.gameId, this.password);
}