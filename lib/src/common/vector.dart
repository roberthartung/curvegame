part of curvegame.common;

class Vector<T extends num> {
  T x;
  
  T y;
  
  Vector(this.x, this.y) {
    double l = length();
    x /= l;
    y /= l;
  }
  
  double length() {
    return math.sqrt(x*x+y*y);
  }
  
  /**
   * Returns a new vector rotates by [degress] degress
   */
  
  Vector rotate(num degrees) {
    double radians = degrees * (math.PI / 180);
    return new Vector(x * math.cos(radians) - y * math.sin(radians), x * math.sin(radians) + y * math.cos(radians));
  }
  
  /**
   * Returns a angle (0..360 degress) which is the angle between the x axis in clock wise rotation 
   */
  
  num angle() {
    num angle = (math.atan2(y,x) - math.atan2(0,1)) * 180 / math.PI;
    if(y < 0) {
      angle += 360;
    }
    return angle;
  }
  
  String toString() {
    return "Vector($x,$y)";
  }
}