part of curvegame.common;

abstract class Player<G> {
  String name;
  
  G game;
  
  bool game_owner = false;
  
  bool isReady = false;
  
  String color = 'red';
  
  math.Point position;
  
  math.Point direction;
  
  num angle;
  
  bool isPlaying = true;
  
  List<math.Point> path = [];
  
  Player(String this.name, G this.game);
}