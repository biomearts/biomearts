PFont font;
int fontSize;

int t_min = 1460820127;
int t_max = 1460939429;
float m_min = 0.4;
float m_max = 0.6;
int maxtime = 43;
JSONArray values;
IntList time;
FloatList moisture;
void setup() {
  //SETUP
  size(200, 200, "processing.core.PGraphicsRetina2D");
  frameRate(32);
  time = new IntList();
  moisture = new FloatList();
  font = loadFont("Akkurat-Mono-48.vlw");
  fontSize = 12;
  textFont(font, fontSize);
  textAlign(LEFT, TOP);

  //DATA IMPORT
  values = loadJSONArray("moisturedata.json");
  println(values.size());
  for (int i = 0; i < values.size(); i++) {
    JSONObject data = values.getJSONObject(i);
    float m = data.getFloat("moisture");
    int t_utc = data.getInt("t_utc");
    time.append(t_utc);
    moisture.append(m);
    
    float time_tran = map(t_utc, t_min, t_min + (t_max - t_min)*0.12, 0, width);
    float moisture_tran = map(m, m_min, m_max, height, 0);
/*
    strokeWeight(1);
    stroke(255);
    point(time_tran, moisture_tran);*/
  }
}

int counter;
float illumination;
String m_str, t_str;
void draw(){
  background(0);
  counter = frameCount%43;
  
  //VISUALIZATION
  illumination = map(moisture.get(counter), m_min, m_max, 0, 255);
  fill(illumination);
  rectMode(RADIUS);
  rect(width/2,height/2,50,50);
  
  //TEXT
  m_str = nf(map(moisture.get(counter), 0, 1, 0, 100), 2, 2) + "%";
  t_str = nf((time.get(counter) - t_min)/60, 4);
  fill(255);
  text(m_str + " moisture", 15,15);
  text(t_str + " minutes", 15,15+fontSize);
}
