int r = 5;
PVector center = new PVector(9, 32); // ref
PVector p = new PVector(23,17); // in local coor
float scale = 1.3;
float rotate = 0.5;

size(200, 200, "processing.core.PGraphicsRetina2D");

pushStyle();
pushMatrix();
  translate(center.x, center.y);
  rotate(rotate);
  scale(scale);
  strokeWeight(1);
  stroke(0,255,0);
  line(0,0,20,0);
  stroke(0,0,255);
  line(0,0,0,20);
  stroke(255, 0, 0);
  ellipse(p.x, p.y, 5, 5);
popMatrix();
popStyle();

println(p);

p.setMag(p.mag()*scale);
p.rotate(rotate);
p.add(center);
ellipse(p.x, p.y, 5, 5);

println(p); // in global coor

p.sub(center);
p.rotate(-rotate);
p.setMag(p.mag()/scale);

println(p); // back in local coor
