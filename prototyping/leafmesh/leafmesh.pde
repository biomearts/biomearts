import java.io.FilenameFilter;

boolean debug = false;
ArrayList<DraggableGrid> grids;
int focus;

PFont font;
int fontSize;

void setup() {
  frameRate(30);
  size(640,360,"processing.core.PGraphicsRetina2D"); // for retina dispaly
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
  }));
  String targetDataFile = dataFiles[dataFiles.length - 1];
  JSONArray data = loadJSONArray("grids/" + targetDataFile);
  println("grid loaded from " + targetDataFile);
  
  // initialize grids from file
  for(int i = 0; i < data.size(); i++) {
    JSONObject obj = data.getJSONObject(i);
    int w = obj.getInt("width");
    int h = obj.getInt("height");
    JSONArray points = obj.getJSONArray("points");
    ArrayList<PVector> vectors = new ArrayList<PVector>();
    for(int j = 0; j < points.size(); j++) {
      JSONArray p = points.getJSONArray(j);
      vectors.add(new PVector(p.getFloat(0), p.getFloat(1)));
    }
    String id = obj.getString("id");
    String background = obj.getString("background");
    JSONObject box = obj.getJSONObject("box");
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
      background, 
      id
    ));
  }
}

void draw() {
  background(0); // reset canvas
  for(DraggableGrid g: grids) {
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
  
  for(int i = 0; i < grids.size(); i++) {
    DraggableGrid g = grids.get(i);
    
    JSONObject obj = new JSONObject();
    if(g.id != null)
      obj.setString("id", g.id);
    if(g.background != null)
      obj.setString("background", g.background);
    if(g.box != null) {
      JSONObject box = new JSONObject();
      box.setFloat("x", g.box.x);
      box.setFloat("y", g.box.y);
      box.setFloat("width", g.box.w);
      box.setFloat("height", g.box.h);
      obj.setJSONObject("box", box);
    }
    obj.setInt("width", g.gridSize[0]);
    obj.setInt("height", g.gridSize[1]);
    
    JSONArray points = new JSONArray();
    for(int j = 0; j < g.size(); j++) {
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

void keyPressed() {
  if(keyCode == 68) { // toggle debug mode @D
    debug = !debug;
  }
  else if(keyCode == 83) { // save @S
    save();
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
