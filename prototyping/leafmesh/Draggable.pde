class Draggable {
// this is a base class for draggable objects

  float xpos, ypos;       //position of object
  float xOffset, yOffset; //
  float r;           //click radius for grabbing
  boolean mouseOver; //if mouse is over the object
  boolean grabbed;   //if user has grabbed the object
  
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
  
  void CheckMouseOver() {
  // check if the user has moused over the (circular) object    
    if ( sqrt((xpos-mouseX)*(xpos-mouseX) + (ypos-mouseY)*(ypos-mouseY)) < r ) {
      mouseOver = true;
      //println("Moused over.");
    } 
    else {
      mouseOver = false;
      //println("Moused gone.");
    }
  }

  void CheckPressed() {
  // check if the use has clicked the mouse while mousing over this object
    if (mouseOver) {
      grabbed = true;
      xOffset = mouseX - (int)xpos; 
      yOffset = mouseY - (int)ypos;
      //println("Object grabbed.");
    }
    else { 
      grabbed = false;
    }
  }

  void Drag() {
    //move ball if it is being dragged
    if ( (grabbed)&&((xpos-r)>=0)&&((xpos+r)<width)&&((ypos-r)>=0)&&((ypos+r)<height) ) {
      xpos = mouseX - xOffset;
      ypos = mouseY - yOffset;
    }
    //ensure ball is within bounds
    if ( (xpos-r) < 0 )      { xpos = r; }
    if ( (xpos+r) >= width ) { xpos = width-r-1; }
    if ( (ypos-r) < 0 )      { ypos = r; }
    if ( (ypos+r) >= height ){ ypos = height-r-1; }
    //println(xpos + "  " + ypos);
  }
  
  void Release() {
  // when mouse button is released, un-grab the object    
    grabbed = false;
    //println("Object let go.");
  }
  
  void Display() {}; // all draggables must have a display function
}

class Circle extends Draggable {
//this is a class for draggable cirlce objects  
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
