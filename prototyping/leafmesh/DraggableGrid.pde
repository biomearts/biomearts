class DraggableGrid extends ArrayList<Draggable> {
// this class is a container for a grid of draggable circles
//  it contains methods for drawing cubic b-splines created by the grid of circles
  
  int[] gridSize;
  float pointRadius = 5.0;
  
  color polyLineColor;
  color bezierCurveColor;
  float polyLineWidth;
  float bezierCurveWidth;
  int lastDraggedIndex;  // index of the last draggable object to be selected
  float[] xPt,yPt;
  color[] colorPt;
  
  BSplineDraw bsplineDrawer;
  
  String background;
  PImage backgroundImage;
  BoundingBox box; // background dimensions & bounding box
  String id;
  
  DataSource ds;
  PVector currentDataEntry; // use this to visualize
  
  PVector center;
  float scale;
  float rotation;
  
  DraggableGrid() {
    bsplineDrawer = new BSplineDraw();
    
    polyLineColor = color(220,220,220);
    bezierCurveColor = color(0,0,0);
    polyLineWidth = 1.0;
    bezierCurveWidth = 1.0;
    
    lastDraggedIndex = 0;
    xPt = new float[4];
    yPt = new float[4];
    colorPt = new color[4];
    
    gridSize = new int[2];
    gridSize[0] = 5;
    gridSize[1] = 5;
    
    background = null;
    id = null;
  }
  
  DraggableGrid(int gridWidth, int gridHeight) {
    this();
    this.gridSize[0] = gridWidth;
    this.gridSize[1] = gridHeight;
    this.SetUpGridPoints();
  }
  
  DraggableGrid(int gridWidth, int gridHeight, ArrayList<PVector> vectors, BoundingBox box, float scale, float rotation, String background, String id) {
    this();
    this.gridSize[0] = gridWidth;
    this.gridSize[1] = gridHeight;
    this.SetUpGridPoints(vectors);
    this.box = box;
    this.center = new PVector((this.box.x+this.box.w)/2, (this.box.y+this.box.h)/2);
    this.scale = scale;
    this.rotation = rotation;
    
    this.background = background;
    this.backgroundImage = loadImage("images/" + background);
    this.id = id;
    
    this.ds = new DataSource("moisturedata.json");
  }

//--- vector magic----------//
  PVector TransformToGlobal(PVector p) {
    return this.TransformToGlobal(p.x, p.y);
  }
  PVector TransformToGlobal(float x, float y) {
    PVector q = new PVector(x, y);
    q.setMag(q.mag()*this.scale);
    q.rotate(this.rotation);
    q.add(this.center);
    return q;
  }
  
  PVector TransformToLocal(PVector p) {
    return this.TransformToLocal(p.x, p.y);
  }
  PVector TransformToLocal(float x, float y) {
    PVector q = new PVector(x, y);
    q.sub(this.center);
    q.rotate(-this.rotation);
    q.setMag(q.mag()/this.scale);
    return q;
  }
  
//--- display functions ----------//
  void draw() {
    pushMatrix();
    translate(this.center.x, this.center.y);
    rotate(this.rotation);
    scale(this.scale);
    this.currentDataEntry = this.ds.getNext();
    if(debug) {
      this.DrawBackground();
    }
    polyLineColor = round(map(this.currentDataEntry.y, this.ds.min.y, this.ds.max.y, 25, 255));
    this.DrawPolyLine();
    //this.DrawBezierCurve();
    if(debug) {
      this.DrawAxes();
      this.DrawPoints();
    }
    this.DrawData();
    this.CheckMouseOver();
    popMatrix();
  }
  
  void DrawData() {
    pushStyle();
    fill(255);
    textAlign(LEFT, TOP);
    text(nf(this.currentDataEntry.y * 100, 2, 2) + "% humidity", 0, 0);
    text(nf(
      (this.currentDataEntry.x - this.ds.min.x)/60, 
      floor(log10((this.ds.max.x - this.ds.min.x)/60)) + 1, 
      2
    ) + " minutes elapsed", 0, 0 + fontSize);
    popStyle();
  }
  
  void DrawBackground() {
    pushStyle();
    image(this.backgroundImage, -this.box.w/2, -this.box.h/2, this.box.w, this.box.h);
    popStyle();
  }
    
  void DrawPoints() {
  //draw all the objects in the set
    pushStyle();
    strokeWeight(1);
    for(int i=0; i<this.size(); ++i) {
      this.get(i).Display();
    }
    popStyle();
  }
  
  void DrawPolyLine() {
  //draw lines between sequential pairs of points
    pushStyle();
    strokeWeight(2);
    stroke(polyLineColor);
    //line(x1,y1,x2,y2);
    
    //draw vertical lines
    for(int i=1; i<gridSize[1]; ++i) {
      for(int j=0; j<gridSize[0]; ++j) {
         line(this.get(j+(i-1)*gridSize[0]).xpos,
              this.get(j+(i-1)*gridSize[0]).ypos,
              this.get(j+i*gridSize[0]).xpos,
              this.get(j+i*gridSize[0]).ypos);
         //println("("+i+","+j+")" + "\t" + (j+(i-1)*gridSize[0]) + " to " + (j+i*gridSize[0]));
      }
    }  
    //draw horizontal lines
    for(int i=0; i<gridSize[1]; ++i) {
      for(int j=1; j<gridSize[0]; ++j) {
         line(this.get((j-1)+i*gridSize[0]).xpos,
              this.get((j-1)+i*gridSize[0]).ypos,
              this.get(j+i*gridSize[0]).xpos,
              this.get(j+i*gridSize[0]).ypos);
      }
    }
    popStyle();
  }

  void DrawBezierCurve() {
  //draw 3rd order bezier curve created by point list
    pushStyle();
    fill(bezierCurveColor); //<>//
    noStroke();

    /*
     ---> j = 0..gridSize[0]
    |          0,        1,     2,
    |  gS[0] + 0,  gS[0]+1,
    v 2gS[0] + 0, 2gS[0]+1,
    i = 0..gridSize[1]
    
    idx = j+i*gS[0]
    */
  
    if(gridSize[0]>4 && gridSize[1]>4) {
      // draw vertical lines
      for(int j=1; j<this.gridSize[0]-1; ++j) {
        for(int i=3; i<this.gridSize[1]; ++i) {
          xPt[0] = this.get(j+(i-3)*gridSize[0]).xpos;
          xPt[1] = this.get(j+(i-2)*gridSize[0]).xpos;
          xPt[2] = this.get(j+(i-1)*gridSize[0]).xpos;
          xPt[3] = this.get(j+i*gridSize[0]).xpos;
          
          yPt[0] = this.get(j+(i-3)*gridSize[0]).ypos;
          yPt[1] = this.get(j+(i-2)*gridSize[0]).ypos;
          yPt[2] = this.get(j+(i-1)*gridSize[0]).ypos;
          yPt[3] = this.get(j+i*gridSize[0]).ypos;
            
          bsplineDrawer.DrawCubicBezier(xPt,yPt,bezierCurveWidth);
        }
      }
        
      // draw horizontal lines
      for(int j=3; j<this.gridSize[0]; ++j) {
        for(int i=1; i<this.gridSize[1]-1; ++i) {
          xPt[0] = this.get((j-3)+i*gridSize[0]).xpos;
          xPt[1] = this.get((j-2)+i*gridSize[0]).xpos;
          xPt[2] = this.get((j-1)+i*gridSize[0]).xpos;
          xPt[3] = this.get(j+i*gridSize[0]).xpos;
          
          yPt[0] = this.get((j-3)+i*gridSize[0]).ypos;
          yPt[1] = this.get((j-2)+i*gridSize[0]).ypos;
          yPt[2] = this.get((j-1)+i*gridSize[0]).ypos;
          yPt[3] = this.get(j+i*gridSize[0]).ypos;
            
          bsplineDrawer.DrawCubicBezier(xPt,yPt,bezierCurveWidth);
        }
      }
      
    } else {
        println("Not enough points to draw cubic b-spline.");
    }
    popStyle();
  }
  
  void DrawAxes() {
    int l = 100;
    pushStyle();
    stroke(0,0,255);
    strokeWeight(5);
    line(0, 0, l, 0);
    stroke(255,0,0);
    line(0, 0, 0, l);
    popStyle();
  }
  
//--- set functions ----------//
  // place numberOfPoints objects in a regular grid
  void SetUpGridPoints() {
    float xSpacing = (width-2*pointRadius)/(this.gridSize[0]-1);
    float ySpacing = (height-2*pointRadius)/(this.gridSize[1]-1);
    float xpos = pointRadius;
    float ypos = pointRadius;
    for(int i=0; i<this.gridSize[1]; ++i) {
      xpos = pointRadius;
      for(int j=0; j<this.gridSize[0]; ++j) {
        this.AddPoint(floor(xpos),floor(ypos));
        xpos += xSpacing; 
      }
      ypos += ySpacing;
    }
  }
  
  void SetUpGridPoints(ArrayList<PVector> vectors) {
    for(PVector v: vectors) {
      this.AddPoint(floor(v.x), floor(v.y));
    }
  }
  
  // add a point to the end of the point list
  void AddPoint(float xpos, float ypos) {
    this.add(new Circle(xpos,ypos,this.pointRadius));
  }
  
  // delete a point from the point list
  void DeletePoint(int index) {
    this.remove(index);
  }
  
//--- mouse functions ----------//
  void CheckMouseOver() {
  // check if the user has moused over any (circular) objects
    for(int i=0; i<this.size(); ++i) {
      this.get(i).CheckMouseOver(this);
    }
  }
  
  // check if the use has clicked the mouse while mousing over this object
  void CheckPressed() {
    for(int i=0; i<this.size(); ++i) {
      this.get(i).CheckPressed(this);
    }
  }
  
  // move ball if it is being dragged
  void DragTopMostObject() {
    lastDraggedIndex = 0;
    
    //only drag the top-most object (top-most is at the end of the list)
    for(int i=1; i<this.size(); ++i) {
      if(this.get(i).grabbed) {                     //if this index is grabbed
        this.get(lastDraggedIndex).grabbed = false; //forget the lower grabbed object 
        lastDraggedIndex = i;                       //set this object as the one to drag
      };
    }
    this.get(lastDraggedIndex).Drag(this);              //drag the selected object
  }
  
  // when mouse button is released, un-grab the object 
  void Release() { 
    for(int i=0; i<this.size(); ++i) {
      this.get(i).Release();
    }
  }
  
  void ResetGrid() {
    this.clear();
    this.SetUpGridPoints();
  }
}

