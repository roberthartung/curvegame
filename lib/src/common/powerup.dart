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

abstract class PowerUp {
  /**
   * Position and ID
   */
  
  math.Point _position;
    
  int _id;
  
  /**
   * Getter
   */
  
  int get id => _id;
  
  math.Point get position => _position;
  
  /**
   * Default constructor
   */
  
  PowerUp(this._id, this._position);
  
  /**
   * toString
   */
  
  String toString() => "[PowerUp#${_id}:${this.runtimeType}]";
}