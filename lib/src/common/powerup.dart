part of curvegame.common;

/**
 * Types of powerups (listed by icon names)
 * 
 * [time]
 *  Global items with limited amount of time, stackable
 * [usable]
 *  Can be used by the player. Only the first collected item can be activated (no skipping/choosing mechanism)
 * 
 * 
 * bug [time]
 *  function: makes yourself slower
 * diamond [own]
 *  function: gives the player X points
 * clock [time]
 *  function: increases the point factor
 * cubes [usable, time]
 *  function: place a random number of blocks on the map for a limited time
 * heart [stack]
 *  function: Prevents the next collision: step over curve of re-enter on the opposite side 
 * rocket [time]
 *  function: make others faster 
 * random [time]
 *  function: invert direction of other players
 * ban [time]
 *  function: 
 */

/*
 const Map<String, dynamic> ICONS = const {
  'rocket': ,         // Makes others faster
  'diamond': ,        // Gives you extra points
  /*'cubes': 0xf1b3,*/
  'cube': ,           // Place cube(s)
  
  'heart': 0xf004,          // Bypass one line
  /*'road': 0xf018,*/
  'random': 0xf074,         // Switch directions
  // 'bomb': 0xf1e2,        // 
  'ban': 0xf05e             // No one draws lines
  
  // Smaller / larger radius
  // Smaller / larger line width
  // Zerfressen von linie (pacman style) -> Punkte klauen
};
enum Target {OTHERS, SELF, ALL}
 */

/*
const int POWERUP_FLAG_SELF = 0x1;
const int POWERUP_FLAG_OTHERS = 0x2;
const int POWERUP_FLAG_MAP = 0x4;
*/

abstract class UsablePowerUp {
  
}

abstract class TimedPowerUp {
  num duration;
  
  num end;
  
  void collected(Player player) {
    Game game = player.game;
    end = game.tickCount + duration*TICKS_PER_SECONDS;
  }
  
  bool tick(int tick) {
    if(end <= tick) {
      onEnd();
      return true;
    }
    
    return false;
  }
  
  void onEnd();
}

/*
abstract class SlowdownPowerUp {
}

abstract class SpeedUpPowerUp {
}

abstract class ExtraPointsPowerUp {
  // _flags |= POWERUP_FLAG_SELF;
}

abstract class CubesPowerUp {
  // _flags |= POWERUP_FLAG_MAP;
}
*/

abstract class PowerUp {
  /**
   * Variables
   */
  
  // String _type;
  
  math.Point _position;
    
  int _id;
  
  /**
   * Internal flags depending on the type
   */
  
  int _flags;
  
  /**
   * Getter
   */
  
  int get id => _id;
  
  math.Point get position => _position;
  
  //String get type => _type;
  
  /**
   * Default constructor
   */
  
  PowerUp(this._id, this._position);
    /*
    switch(_type) {
      case 'bug' :
      case 'diamond' :
      case 'cube' :
      case 'heart' :
        _flags |= POWERUP_FLAG_SELF; 
        //_target = Target.SELF;
        break;
      case 'rocket' :
      case 'random' :
        _flags |= POWERUP_FLAG_OTHERS; 
        //_target = Target.OTHERS;
        break;
      case 'ban' :
        //_target = Target.ALL;
        break;
    }
    */
  
  /**
   * toString
   */
  
  String toString() => "[PowerUp#${_id}:${this.runtimeType}]";
}