import java.io.FilenameFilter;

boolean debug = true;
ArrayList<DraggableGrid> grids;
int focus;

PFont font;
int fontSize;

void setup() {
  frameRate(30);
  size(900, 900, "processing.core.PGraphicsRetina2D"); // for retina dispaly
  //pixelDensity(2); // Processing 3
  font = loadFont("Akkurat-Mono-48.vlw");
  fontSize = 12;
  textFont(font, fontSize);
  grids = new ArrayList<DraggableGrid>();
  focus = 0; // always 0 for now

  // load the last-saved data file
  File dataFolder = new File(dataPath("") + "/grids");
  String[] dataFiles = sort(dataFolder.list(new FilenameFilter() {
    @Override
      public boolean accept(File dir, String name) {
      return (name.lastIndexOf(".json") == name.length() - 5); // is a JSON file
    }
  }
  ));
  String targetDataFile = dataFiles[dataFiles.length - 1];
  JSONArray data = loadJSONArray("grids/" + targetDataFile);
  println("grid loaded from " + targetDataFile);

  // initialize grids from file
  for (int i = 0; i < data.size (); i++) {
    JSONObject obj = data.getJSONObject(i);
    int w = obj.getInt("width");
    int h = obj.getInt("height");
    JSONArray points = obj.getJSONArray("points");
    ArrayList<PVector> vectors = new ArrayList<PVector>();
    for (int j = 0; j < points.size (); j++) {
      JSONArray p = points.getJSONArray(j);
      vectors.add(new PVector(p.getFloat(0), p.getFloat(1)));
    }
    String id = obj.getString("id");
    String background = obj.getString("background");
    JSONObject box = obj.getJSONObject("box");
    float scale = obj.getFloat("scale");
    float rotation = obj.getFloat("rotation");
    grids.add(new DraggableGrid(
    w, 
    h, 
    vectors, 
    new BoundingBox(
    box.getFloat("x"), 
    box.getFloat("y"), 
    box.getFloat("width"), 
    box.getFloat("height")
      ), 
    scale, 
    rotation, 
    background, 
    id
      ));
  }

  println("");
  println("//BASICS//");
  println("D -> debug mode");
  println("S -> save all grids");
  println("//GRID MANIPULATION//");
  println("\t       B");
  println("\t       ↑     R");
  println("\t  ┌─┬─┬─┬─┬─┐");
  println("\t  ├─┼─┼─┼─┼─┤");
  println("\tA←├─┼─┼─┼─┼─┤→X");
  println("\t  ├─┼─┼─┼─┼─┤");
  println("\t  └─┴─┴─┴─┴─┘");
  println("\t       ↓");
  println("\t       Y     S");
  println("[ -> decrement");
  println("] -> increment");
}

void draw() {
  background(0); // reset canvas
  for (DraggableGrid g : grids) {
    g.draw(); // draw each grid
  }
}

String getDateTime() { // get current datetime for data file name
  return 
    nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "T" + 
    nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
}
void save() {
  // construct JSON array from grids
  JSONArray data = new JSONArray();

  for (int i = 0; i < grids.size (); i++) {
    DraggableGrid g = grids.get(i);

    JSONObject obj = new JSONObject();
    if (g.id != null)
      obj.setString("id", g.id);
    if (g.background != null)
      obj.setString("background", g.background);
    if (g.box != null) {
      JSONObject box = new JSONObject();
      box.setFloat("x", g.box.x);
      box.setFloat("y", g.box.y);
      box.setFloat("width", g.box.w);
      box.setFloat("height", g.box.h);
      obj.setJSONObject("box", box);
    }
    obj.setFloat("scale", g.scale);
    obj.setFloat("rotation", g.rotation);
    obj.setInt("width", g.gridSize.x);
    obj.setInt("height", g.gridSize.y);

    JSONArray points = new JSONArray();
    for (int j = 0; j < g.size (); j++) {
      JSONArray p = new JSONArray();
      p.setFloat(0, g.get(j).xpos);
      p.setFloat(1, g.get(j).ypos);
      points.setJSONArray(j, p);
    }
    obj.setJSONArray("points", points);

    data.setJSONObject(i, obj);
  }
  // save data to file
  String fileName = getDateTime() + ".json";
  saveJSONArray(data, "data/grids/" + fileName, null);
  println("grid saved at " + fileName);
}

Mode mode = new Mode();

void keyPressed() {
  if (keyCode == 68) { // toggle debug mode @D
    debug = !debug;
  } else if (keyCode == 83) { // save @S
    save();
  } else if (keyCode == 82) { // rotate @R
    mode.action = Mode.ROTATE;
    println("ROTATE");
  } else if (keyCode == 76) { // scale @L
    mode.action = Mode.SCALE;
    println("SCALE");
  } else if (keyCode == 65) { // A
    mode.action = Mode.HORIZONTAL;
    mode.pos = Mode.BEGIN;
    println("INSERT COL/DELETE FIRST COL");
  } else if (keyCode == 66) { // B
    mode.action = Mode.VERTICAL;
    mode.pos = Mode.BEGIN;
    println("INSERT ROW/DELETE FIRST ROW");
  } else if (keyCode == 88) { // X
    mode.action = Mode.HORIZONTAL;
    mode.pos = Mode.END;
    println("APPEND COL/DELETE LAST COL");
  } else if (keyCode == 89) { // Y
    mode.action = Mode.VERTICAL;
    mode.pos = Mode.END;
    println("APPEND ROW/DELETE LAST ROW");
  } else if (keyCode == 91 || keyCode == 93) { // [ & ]
    int dir = int(constrain(keyCode - 92, -1, 1));
    float delta = float(dir)/100.0;
    DraggableGrid grid = grids.get(focus);
    switch(mode.action) {
    case Mode.ROTATE:
      grid.rotation += delta;
      break;
    case Mode.SCALE:
      grid.scale += delta;
      break;
    case Mode.HORIZONTAL:
      grid.Horizontal(mode.pos, dir);
      break;
    case Mode.VERTICAL:
      grid.Vertical(mode.pos, dir);
      break;
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {   // left click to drag points drag
    grids.get(focus).CheckPressed();
  }                                                   
  if (mouseButton == RIGHT) {  // right click to reset control point grid
    grids.get(focus).ResetGrid();
  }
}

void mouseDragged() {
  grids.get(focus).DragTopMostObject();
}

void mouseReleased() {
  grids.get(focus).Release();
}

