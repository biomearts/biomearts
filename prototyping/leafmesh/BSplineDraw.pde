// modified from http://ww.wiredpieces.com/sketch/214691

class BSplineDraw {
/*
This class takes 4 control points and draws one segment of a cubic b-spline.

Equation for cubic b-spline taken from:
http://www2.cs.uregina.ca/~anima/408/Notes/Interpolation/UniformBSpline.htm

P(u) = U*B*P'

cubic b-spline coefficient matrix:
B=[[-1,3,-3,1],
   [3,-6,3,0],
   [-3,0,3,0],
   [1,4,1,0]]  /6.0

time matrix has 100 rows, ranging from u=0.0 to u=1.0:
U = [u^3 u^2 u 1]

point vector of 4 control points
P = [P(i-3) P(i-2) P(i-1) P(i)]
*/

  int numberOfPointsInCurve = 200;
  float spacing;
  float[][] U; 
  float[][] B ={  {-1/6.0,   3/6.0, -3/6.0, 1/6.0},
                  { 3/6.0,  -6/6.0,  3/6.0,   0.0},
                  {-3/6.0,     0.0,  3/6.0,   0.0},
                  { 1/6.0,   4/6.0,  1/6.0,   0.0}  };
  float[] xWeight, yWeight;

  BSplineDraw() {
    this.U = new float[numberOfPointsInCurve][4];
    this.spacing = 1/(float)numberOfPointsInCurve;
    this.MakeTimeMatrix();
    this.xWeight = new float[4];
    this.yWeight = new float[4];
  }

  void MakeTimeMatrix() {
    float temp = 1.0;   // value to be assigned to matrx
    float u = 0.0;      // time value (multiplication factor for each new column)
    for(int row=0; row<numberOfPointsInCurve; ++row) { 
      temp = 1.0;
      for(int col=3; col>=0; --col) {
        U[row][col] = temp;
        temp *= u;
      }
      u += spacing; //increase u from 0 to 1;
    }
  }
                  
  void PrintTimeMatrix() {
    for(int row=0; row<numberOfPointsInCurve; ++row) { 
      for(int col=0; col<4; ++col) {
        print(U[row][col] + "\t\t");
      }
      print("\n");
    }
  }
 
  void DrawCubicBezier(float[] x, float[] y, float radius) {
      float xdraw, ydraw;
      
      //ellipseMode(RADIUS);
      loadPixels();
      
      // calculate weights
      for(int i=0; i<4; ++i) {
        xWeight[i] = B[i][0]*x[0] + B[i][1]*x[1] + B[i][2]*x[2] + B[i][3]*x[3];
        yWeight[i] = B[i][0]*y[0] + B[i][1]*y[1] + B[i][2]*y[2] + B[i][3]*y[3];
      }

      // draw points
      for(int i=0; i<numberOfPointsInCurve; ++i) {
        xdraw = U[i][0]*xWeight[0] + U[i][1]*xWeight[1] + U[i][2]*xWeight[2] + U[i][3]*xWeight[3];
        ydraw = U[i][0]*yWeight[0] + U[i][1]*yWeight[1] + U[i][2]*yWeight[2] + U[i][3]*yWeight[3];
        pixels[int(xdraw) + int(ydraw)*width] = color(0,0,0);
        //pixels[j+i*width];        
        //ellipse(int(xdraw),int(ydraw),radius,radius);
      }
      updatePixels();
    }                                    
                  
                  
  void DrawColoredCubicBezier(float[] x, float[] y, color[] c) {
    color myColor = color(0,0,0);
    int red,green,blue;
    float xdraw, ydraw;
    
    ellipseMode(RADIUS);
    noStroke();
    //loadPixels();

    // calculate weights
    for(int i=0; i<4; ++i) {
      xWeight[i] = B[i][0]*x[0] + B[i][1]*x[1] + B[i][2]*x[2] + B[i][3]*x[3];
      yWeight[i] = B[i][0]*y[0] + B[i][1]*y[1] + B[i][2]*y[2] + B[i][3]*y[3];
    }
    fill(myColor);
    
    // draw points
    for(int i=0; i<numberOfPointsInCurve; ++i) {
      xdraw = U[i][0]*xWeight[0] + U[i][1]*xWeight[1] + U[i][2]*xWeight[2] + U[i][3]*xWeight[3];
      ydraw = U[i][0]*yWeight[0] + U[i][1]*yWeight[1] + U[i][2]*yWeight[2] + U[i][3]*yWeight[3];
      //pixels[int(xdraw) + int(ydraw)*width] = color(0,0,0);
      //pixels[j+i*width];
      ellipse(int(xdraw),int(ydraw),1.0,1.0);
    }
    //updatePixels();
  }
}
