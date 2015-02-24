part of curvegame.common;

class Entity {
  String type;
  
  int x;
  
  int y;
  
  Target target = null;
  
  Entity(this.type, this.x, this.y) {
    switch(type) {
      case 'bug' :
      case 'diamond' :
      case 'cube' :
      case 'heart' :
          target = Target.SELF;
        break;
      case 'random' :
          target = Target.OTHERS;
        break;
      case 'ban' :
          target = Target.ALL;
        break;
    }
  }
  
  Map toObject() {
    return {'type': type, 'position': {'x': x, 'y': y}, 'target': target.index};
  }
}

class DrawableEntity extends Entity {
  String iconText;
  
  DrawableEntity.fromObject(Map obj) : super(obj['type'], obj['position']['x'], obj['position']['y']) {
    iconText = new String.fromCharCode(ICONS[type]);
  }
}