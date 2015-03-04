part of curvegame.client;

abstract class PowerUp extends common.PowerUp {
  PowerUp.fromObject(icon, Map object) : super(object['id'], new Point(object['position']['x'], object['position']['y'])) {
    iconText = new String.fromCharCode(icon);
  }
  
  String iconText;
  
  void draw(CanvasRenderingContext2D ctx) {
    // Draw function for the frontend
    ctx.fillStyle = 'green';
    ctx.beginPath();
    ctx.arc(position.x, position.y, 15, 0, 2*PI);
    ctx.closePath();
    ctx.fill();
    
    // TODO(rh): Color from PowerUp's target
    ctx.font = '20px FontAwesome';
    ctx.textBaseline = 'top';
    ctx.textAlign = 'left';
    ctx.fillStyle = 'white';
    TextMetrics metrics = ctx.measureText(iconText);
    ctx.fillText(iconText, position.x - metrics.width/2, position.y-10);
  }
  
  // TODO(rh): more powerups
  static PowerUp instanceFomObject(Map object) {
    switch(object['type']) {
      case 'SlowdownPowerUp' :
        return new SlowdownPowerUp.fromObject(object);
      case 'SpeedUpPowerUp' :
        return new SpeedUpPowerUp.fromObject(object);
      case 'ExtraPointsPowerUp' :
        return new ExtraPointsPowerUp.fromObject(object);
      case 'CubesPowerUp' :
        return new CubesPowerUp.fromObject(object);
    }
    
    return null;
  }
}

/**
 * Concrete power up implementations for the client
 */

class SlowdownPowerUp extends PowerUp {
  static final int ICON = 0xf188; // bug
  
  SlowdownPowerUp.fromObject(Map d) : super.fromObject(ICON, d);
}

class SpeedUpPowerUp extends PowerUp {
  static final int ICON = 0xf135; // rocket
  
  SpeedUpPowerUp.fromObject(Map d) : super.fromObject(ICON, d);
}

class ExtraPointsPowerUp extends PowerUp {
  static final int ICON = 0xf219; // diamond
  
  ExtraPointsPowerUp.fromObject(Map d) : super.fromObject(ICON, d);
}

class CubesPowerUp extends PowerUp {
  static final int ICON = 0xf1b2; // cube
  
  CubesPowerUp.fromObject(Map d) : super.fromObject(ICON, d);
}