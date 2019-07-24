class Laser {

  float x, y, width, height, angle;
  boolean held;

  Laser(float x, float y, float width, float height, float angle) {
    this.x = x;
    this.y = y;
    this.height = height;
    this.width = width;
    this.angle = angle;
    held = false;
  }
}
