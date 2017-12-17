class CrossingDetectEngine { //<>//

  PApplet p;
  int wsize;

  CrossingDetectEngine(PApplet pa, int w) {
    p=pa;
    wsize=w;

    if (wsize%2==0) 
      wsize=wsize+1;
  }


  void showHit_v1a() {
    boolean hit=interceptFilter(mouseX, mouseY, wsize, img);    
    p.stroke(0, 255, 0);
    p.rect(mouseX-wsize/2, mouseY-wsize/2, wsize, wsize);
    p.stroke(255, 0, 0);
    if (hit) p.ellipse(mouseX, mouseY, 10, 10);
  }

  void showHit_v1b() {
    boolean hit=interceptFilter2(mouseX, mouseY, wsize, img);    
    p.stroke(0, 255, 0);
    p.rect(mouseX-wsize/2, mouseY-wsize/2, wsize, wsize);
    p.stroke(255, 0, 0);
    if (hit) p.ellipse(mouseX, mouseY, 10, 10);
  }

  void showHit_v2(boolean showConvolutionResults) {

    PImage grmax=createImage(p.width, p.height, RGB);
    grmax.loadPixels();
    for (int x=0; x<p.width; x++)
      for (int y=0; y<p.height; y++) {
        float[] gvals=interceptFilterCalc(x, y, wsize, img);
        float pxsum=sumProc(gvals);
        grmax.pixels[x+y*p.width]=lerpColor(color(0, 100, 255), color(255, 150, 0), pxsum*0.5/getMaxPerQuadrant());
      }

    grmax.updatePixels();
    if (showConvolutionResults) 
      p.image(grmax, 0, 0);
  }

  ArrayList<PVector> getHit_v2() { 

    ArrayList<PVector> hits=new  ArrayList<PVector>();

    stroke(255, 25, 255);
    for (int x=0; x<p.width; x++)
      for (int y=0; y<p.height; y++) {

        boolean hit=interceptFilter2(x, y, wsize, img);
        if (hit) {
          p.ellipse(x, y, 10, 10);
          hits.add(new PVector(x, y));
        }
      }

    return hits;
  }


  float sumProc(float[] ints) {
    return ints[0]+ints[1]+ints[2]+ints[3];
  }

  boolean orOp(float a, float b) {
    return boolean((int)a) | boolean((int)b);
  }

  boolean andOp(float a, float b) {
    return boolean((int)a) & boolean((int)b);
  }

  float getMaxPerQuadrant() {
    return 0.5*(255*(wsize-3));
  }

  /**
   *  First version: Calculating corners based on integrating the differential of T,R,L,R
   *  Detects intercepts type corners (aka. right angles) but not T or line over line intercepts
   */

  boolean interceptFilter(int x, int y, int wsize, PImage m) {

    boolean isCorner=false;

    float intTop=0;  //1
    float intBot=0;  //2
    float intLeft=0; //3
    float intRight=0;//4


    //Make the window size odd
    if (wsize%2==0) 
      wsize=wsize+1;

    int offset=wsize>>1;

    x=constrain(x, offset, width-offset);
    y=constrain(y, offset, height-offset);


    for (int i=-offset+1; i<0; i++) {
      int locc=y*width+x+i;
      float diff=(pixels[locc]&0xff)-(pixels[locc-1]&0xff);
      if (diff!=0)set(x+i, y, color(0, 0, 255));
      intLeft+=diff;
    }

    for (int i=1; i<offset; i++) {
      int locc=y*width+x+i;
      float diff=(pixels[locc]&0xff)-(pixels[locc+1]&0xff);
      if (diff!=0)set(x+i, y, color(250, 0, 150));
      intRight+=diff;
    }

    for (int i=-offset+1; i<0; i++) {
      int locc=(y+i)*width+x;
      int loco=(y+i-1)*width+x;
      float diff=(pixels[locc]&0xff)-(pixels[loco]&0xff);
      if (diff!=0)set(x, y+i, color(255, 0, 150));
      intTop+=diff;
    }

    for (int i=1; i<offset; i++) {
      int locc=(y+i)*width+x;
      int loco=(y+i+1)*width+x;
      float diff=(pixels[locc]&0xff)-(pixels[loco]&0xff);
      if (diff!=0)set(x, y+i, color(0, 0, 255));
      intBot+=diff;
    }

    println("Integrals "+intTop+" "+intBot+" "+intLeft+" "+intRight);
    println("PAirWise Analysis @ "+frameCount);
    println("TL: "+orOp(intTop, intLeft)+"..."+andOp(intTop, intLeft));
    println("TR: "+orOp(intTop, intRight)+"..."+andOp(intTop, intRight));
    println("BL: "+orOp(intBot, intLeft)+"..."+andOp(intBot, intLeft));
    println("BR: "+orOp(intBot, intRight)+"..."+andOp(intBot, intRight));

    isCorner=andOp(intTop, intLeft) || andOp(intTop, intRight);
    isCorner|=andOp(intBot, intLeft) || andOp(intBot, intRight);

    return isCorner;
  }

  /**
   * Detect corners but measuring the maxima or a cross operation.
   * Cross operation defined as the integral from a x,y point, w/2 number
   * of bins N,S,W,E so to get 4 numbers. If you add the 4 components, 
   * you get the following cases: 
   * Maxima at line crossing line
   * Maxima*0.75 at crossing type T
   * Maxima*0.5 at corner
   * Then to find a corner or an intercept, one needs to test for integration
   * values of each component to see if they are a maxima under certain conditions.
   */


  boolean interceptFilter2(int x, int y, int wsize, PImage m) { 

    float[] ret=interceptFilterCalc(x, y, wsize, m);
    return procFilterCalc(ret, wsize);
  }


  float[] interceptFilterCalc(int x, int y, int wsize, PImage m) {

    boolean isCorner=false;
    float[] ints=new float[4];

    float intTop=0;  //1
    float intBot=0;  //2
    float intLeft=0; //3
    float intRight=0;//4

    ////Make the window size odd
    //if (wsize%2==0) 
    //  wsize=wsize+1;

    int offset=wsize>>1;

    x=constrain(x, offset, width-offset);
    y=constrain(y, offset, height-offset);


    for (int i=-offset+1; i<0; i++) {
      int locc=y*width+x+i;
      float sumBin=(pixels[locc]&0xff);
      //if (sumBin!=0)set(x+i, y, color(0, 0, 255));
      intLeft+=sumBin;
    }

    for (int i=1; i<offset; i++) {
      int locc=y*width+x+i;
      float sumBin=(pixels[locc]&0xff);
      //if (sumBin!=0)set(x+i, y, color(250, 0, 150));
      intRight+=sumBin;
    }

    for (int i=-offset+1; i<0; i++) {
      int locc=(y+i)*width+x;
      int loco=(y+i-1)*width+x;
      float sumBin=(pixels[locc]&0xff);
      //if (sumBin!=0)set(x, y+i, color(255, 0, 150));
      intTop+=sumBin;
    }

    for (int i=1; i<offset; i++) {
      int locc=(y+i)*width+x;
      int loco=(y+i+1)*width+x;
      float sumBin=(pixels[locc]&0xff);
      //if (sumBin!=0)set(x, y+i, color(0, 0, 255));
      intBot+=sumBin;
    }

    //println("Integrals "+intTop+" "+intBot+" "+intLeft+" "+intRight);
    //println("PAirWise Analysis @ "+frameCount);
    //println("TL: "+orOp(intTop, intLeft)+"..."+andOp(intTop, intLeft));
    //println("TR: "+orOp(intTop, intRight)+"..."+andOp(intTop, intRight));
    //println("BL: "+orOp(intBot, intLeft)+"..."+andOp(intBot, intLeft));
    //println("BR: "+orOp(intBot, intRight)+"..."+andOp(intBot, intRight));

    ints[0]=intTop;
    ints[1]=intBot;
    ints[2]=intLeft;
    ints[3]=intRight;

    return ints;
  }



  boolean procFilterCalc(float[] aints, int wsize) {

    float intTop=aints[0];  //1
    float intBot=aints[1];  //2
    float intLeft=aints[2]; //3
    float intRight=aints[3];//4

    ////Make the window size odd
    //if (wsize%2==0) 
    //  wsize=wsize+1;

    float valMax=getMaxPerQuadrant();//0.5*(255*(wsize-3));


    //This condition is enough for corner, T and cross intercepts
    if ((intLeft==valMax || intRight==valMax) && (intTop==valMax || intBot==valMax)) {
      println("corner");
      return true;
    }

    if ((intLeft==valMax && intRight==valMax) && (intTop==valMax || intBot==valMax)) {
      println("case2");
      //
      //
      //_____________
      //      |
      //      |
      return true;
    }

    if ((intLeft==valMax || intRight==valMax) && (intTop==valMax && intBot==valMax)) {
      println("case3");
      //      |
      //      |
      //      |______
      //      |
      //      |
      return true;
    }

    if ((intLeft==valMax && intRight==valMax) && (intTop==valMax && intBot==valMax)) {
      println("case4");
      //      |
      //      |
      //______|______
      //      |
      //      |
      return true;
    }

    return false;
  }
}