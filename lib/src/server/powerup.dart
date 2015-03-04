part of curvegame.server;

/**
 * PowerUp class to force methods:
 *    collected([Player])
 */

abstract class PowerUp extends common.PowerUp {
  PowerUp(id, position) : super(id, position);
  
  /**
   * Converts the powerup to a object (map) representation
   */
  
  Map toObject() {
    return {'type': this.runtimeType.toString(), 'position': {'x': position.x, 'y': position.y}, 'id': id};
  }
  
  /**
   * Called when this powerup was collected by a [Player]
   */
  
  void collected(Player player);
  
  /**
   * Called when the powerup was collected and is still active 
   */
  
  bool tick(int tick);
}

/*
// Increase line width
game.lineWidth = 8;
new Timer(new Duration(seconds: 5), () {
  lineWidth = common.DEFAULT_LINE_WIDTH;
  
  // TODO(rh): Duplicate segment type with new line width
  players.forEach((Player player) {
    if(player.currentSegment is common.ArcSegment) {
      common.ArcSegment arc = player.currentSegment as common.ArcSegment;
      player.beginArc(arc.direction);
    } else if(player.currentSegment is common.LineSegment) {
      common.LineSegment line = player.currentSegment as common.LineSegment;
      player.beginLine();
    }
  });
});
*/

/**
 * Concrete power up implementations for the server
 */

class SlowdownPowerUp extends PowerUp with common.TimedPowerUp { /* with common.SlowdownPowerUp */
  Player player;
  
  SlowdownPowerUp(id, position) : super(id, position) {
    duration = 5;
  }
  
  void collected(Player player) {
    super.collected(player);
    this.player = player;
    player.arcStep /= 2;
    player.lineStep /= 2;
  }
  
  void onEnd() {
    player.arcStep *= 2;
    player.lineStep *= 2;
  }
}

class SpeedUpPowerUp extends PowerUp with common.TimedPowerUp {
  Player player;
  
  SpeedUpPowerUp(id, position) : super(id, position) {
    duration = 5;
  }
  
  void collected(Player player) {
    super.collected(player);
    this.player = player;
    Game game = player.game;
    // Speed up other players
    game.players.where((Player otherPlayer) => otherPlayer != player).forEach((Player otherPlayer) {
      otherPlayer.lineStep *= 2;
      otherPlayer.arcStep *= 2;
    });
  }
  
  void onEnd() {
    Game game = player.game;
    game.players.where((Player otherPlayer) => otherPlayer != player).forEach((Player otherPlayer) {
      otherPlayer.lineStep /= 2;
      otherPlayer.arcStep /= 2;
    });
  }
}