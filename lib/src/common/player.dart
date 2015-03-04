part of curvegame.common;

abstract class Player<G> {
  String name;
  
  G game;
  
  bool game_owner = false;
  
  bool isReady = false;
  
  String color = 'red';
  
  math.Point position;
  
  Vector direction;
  
  bool isPlaying = true;
  
  PathSegment currentSegment;
  
  // List<math.Point> path = [];
  
  List<PathSegment> pathSegments = [];
  
  num distance = 0;
  
  Player(String this.name, G this.game);
}