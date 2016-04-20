class BoundingBox {
  float x, y, w, h;
  BoundingBox(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}

float log10 (float x) {
  return (log(x) / log(10));
}
