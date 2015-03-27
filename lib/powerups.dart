part of curvegame;

abstract class PowerUpFactory {
  PowerUp spawn();
}

class CurveGamePowerUpFactory implements PowerUpFactory {
  final CurveGame game;
  
  CurveGamePowerUpFactory(this.game);
  
  int _powerUpId = 0;
  
  PowerUp spawn() {
    Random random = new Random();
    Point position = new Point(random.nextInt(game.width), random.nextInt(game.height));
    int id = _powerUpId++;
    PowerUp powerUp;
    switch(new Random().nextInt(5)) {
      case 0 :
          
        break;
    }
    
    return powerUp;
  }
}

class PowerUpProvider {
  final List<PowerUp> powerUps = [];

  final List<PowerUp> activePowerUps = [];

  int nextPowerUpSpawnTick = TICKS_PER_SECONDS * 5;

  final P2PGame game;
  
  final PowerUpFactory factory;

  PowerUpProvider(this.game, this.factory);

  void tick(int tickCount) {
    if (tickCount == nextPowerUpSpawnTick) {
      spawnPowerUp();
      Random random = new Random();
      nextPowerUpSpawnTick = tickCount + TICKS_PER_SECONDS * (3 + random.nextInt(5));
    }
    
    // Check active power ups
    List<PowerUp> expiredPowerUps = [];
    activePowerUps.forEach((PowerUp powerUp) {
      if (powerUp.tick(tickCount)) {
        print('[PowerUp] $powerUp expired.');
        expiredPowerUps.add(powerUp);
      }
    });
    activePowerUps.removeWhere((PowerUp e) => expiredPowerUps.contains(e));
    
    // Check if a player collected a [PowerUp]
    game.players.forEach((Player player) {
      // Only make tick for player if playing
      // TODO(rh): re-implement
      if (true /*player.isAlive*/) {
        // Check if a power up was collected
        List<PowerUp> powerUpsToRemove = [];
        powerUps.forEach((PowerUp powerUp) {
          // 15 = radius of circle around icon
          // TODO(rh): Make 15 a const
          if (powerUp.position.distanceTo((player as CurveGamePlayer).position) <= 15) {
            powerUpCollected(powerUp, player);
            powerUpsToRemove.add(powerUp);
          }
        });
        powerUps.removeWhere((PowerUp e) => powerUpsToRemove.contains(e));
        powerUpsToRemove.clear();
      }
    });
  }

  void spawnPowerUp() {
    //powerUps.add(factory.spawn());
    /*
    players.forEach((Player player) {
      player.send({'type': 'spawn_powerup', 'powerup': powerUp});
    });
    */
  }

  /**
  * A [Player] collected a [PowerUp]
  */

  void powerUpCollected(PowerUp powerUp, Player player) {
    activePowerUps.add(powerUp);
    // Depending on the type, some actions have to be taken
    powerUp.collected(player);
    print('[PowerUp] Player ${player} collected $powerUp');
    /*
    game.players.forEach((Player player) {
      player.send({'type': 'collect_powerup', 'powerup': powerUp});
    });
    */
  }
}

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
    CurveGame game = player.game;
    end = game.tickCount + duration * TICKS_PER_SECONDS;
  }

  bool tick(int tick) {
    if (end <= tick) {
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

  Point _position;

  int _id;

  /**
   * Getter
   */

  int get id => _id;

  Point get position => _position;

  /**
   * Default constructor
   */

  PowerUp(this._id, this._position);

  /**
   * toString
   */

  String toString() => "[PowerUp#${_id}:${this.runtimeType}]";
  
  void collected(Player player);
  
  bool tick(int tick);
}
