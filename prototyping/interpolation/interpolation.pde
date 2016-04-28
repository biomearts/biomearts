// Constants
int X_AXIS = 2;
color b1, b2, c1, c2;
int counter = 0;

void setup() {
  size(900, 900);
  // Define colors
  b1 = color(255);
  b2 = color(0);
  c1 = color(0);
  c2 = color(255);
}

void draw() {
  background(0);
  if (counter==400) {
    counter=0;
  } else {
    counter++;
  }
  setSpineGradient(50, 190, 540, .5, c2, c1, X_AXIS);
  setLineGradient(100, 190, 540, .5, c2, c1, X_AXIS);
  //  setLineGradient(200, 190, 540, .5, c2, c1, X_AXIS);
  //  setLineGradient(300, 190, 540, .5, c2, c1, X_AXIS);
  println(mouseY);
}

void setSpineGradient(int x, int y, float w, float h, color c1, color c2, int axis) {
  noFill();
  for (int i = x; i <= x+w; i++) { //changed from i++;
    float inter = map(i, 0, counter*4, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(i, y, i, y+h);
  }
}
void setLineGradient(int x, int y, float w, float h, color c1, color c2, int axis) {
  for (int i = x; i <= x+w; i++) { //changed from i++;
    float inter = map(i, 0, counter*4, 0, 1);
    color c = lerpColor(c1, c2, inter);
    line(i, y, i, y+h);
    stroke(c);
    line(x, 190+i, x, 90+i);
    line(x, 290-i, x, 90-i);
  }
}

