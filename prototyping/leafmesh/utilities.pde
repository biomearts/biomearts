import java.util.Calendar;
import java.util.TimeZone;

// functions
float log10 (float x) {
  return (log(x) / log(10));
}

// classes
class BoundingBox {
  float x, y, w, h;
  BoundingBox(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}
class IntVector {
  int x;
  int y;
  IntVector(int x, int y) {
    this.x = x;
    this.y = y;
  }
  String toString() {
    return "(" + x + "," + y + ")";
  }
}
class Mode {
  static final int ROTATE = 10;
  static final int SCALE = 11;
  static final int HORIZONTAL = 12;
  static final int VERTICAL = 13;
  static final int BEGIN = -1;
  static final int END = 1;
  int action = 0;
  int pos = 0;
}
void _(int n) {
  println(frameCount + ":" + n);
}
void _(String str) {
  println(frameCount + ":" + str);
}
String getUTCTime() { // get current datetime for data file name
  Calendar c = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
  return String.valueOf(c.getTimeInMillis());
}
