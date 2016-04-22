// this is a base class for draggable objects
class Draggable {
  float xpos, ypos;       //position of object
  float xOffset, yOffset; //
  float r;                //click radius for grabbing
  boolean mouseOver;      //if mouse is over the object
  boolean grabbed;        //if user has grabbed the object
  
  color fillColor;
  
  Draggable(float xpos, float ypos, float radius) {
    this.xpos = xpos;
    this.ypos = ypos;
    this.r = radius;
    this.xOffset = 0;
    this.yOffset = 0;
    this.mouseOver = false;
    this.grabbed = false;
  }
  
  // check if the user has moused over the (circular) object
  void CheckMouseOver(DraggableGrid grid) {
    PVector mpos = grid.TransformToLocal(new PVector(mouseX, mouseY));
    if ( sqrt((xpos-mpos.x)*(xpos-mpos.x) + (ypos-mpos.y)*(ypos-mpos.y)) < r ) {
      mouseOver = true;
      //println("Moused over.");
    } 
    else {
      mouseOver = false;
      //println("Moused gone.");
    }
  }
  
  // check if the use has clicked the mouse while mousing over this object
  void CheckPressed(DraggableGrid grid) {
    if (mouseOver) {
      PVector mpos = grid.TransformToLocal(mouseX, mouseY);
      grabbed = true;
      xOffset = mpos.x - (int)xpos;
      yOffset = mpos.y - (int)ypos;
      //println("Object grabbed.");
    }
    else {
      grabbed = false;
    }
  }

  void Drag(DraggableGrid grid) {
    //move ball if it is being dragged
    if(grabbed) {
      PVector mpos = grid.TransformToLocal(constrain(mouseX, r, width-r), constrain(mouseY, r, height-r)); 
      xpos = mpos.x - xOffset;
      ypos = mpos.y - yOffset;
    }
  }
  
  // when mouse button is released, un-grab the object
  void Release() {  
    grabbed = false;
    //println("Object let go.");
  }
  
  // all draggables must have a display function
  void Display() {};
  
  // stringify
  String toString() {
    return "(" + this.xpos + "," + this.ypos + ")";
  }
}

// this is a class for draggable cirlce objects
class Circle extends Draggable {
  color fillColor, fillColorInteracted, strokeColor;
    
  Circle (float xpos, float ypos, float radius) {
    super(xpos,ypos,radius);
    this.fillColor = color(0,0,255);
    this.fillColorInteracted = color(255,0,0);
    this.strokeColor = color(0,0,0);
  }
    
  Circle (float xpos, float ypos, float radius, color fillColor, color strokeColor) {
    super(xpos, ypos,radius);
    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
  }    
    
  void Display() {
    ellipseMode(RADIUS);
    fill(mouseOver || grabbed ? fillColorInteracted : fillColor);
    stroke(strokeColor);
    ellipse(this.xpos,this.ypos,this.r,this.r);
  }
}
