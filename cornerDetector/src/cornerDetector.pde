/** //<>// //<>// //<>//
 * Convolution
 * by Daniel Shiffman.  
 * 
 * Applies a convolution matrix to a portion of an image. Move mouse to 
 * apply filter to different parts of the image. This example is currently
 * not accurate in JavaScript mode.
 */

final int WINSIZE=50;
final int LINEWIDTH=10;

PImage img;

boolean execFilter1=false;
boolean execFilter2=false;
boolean execFilter9=false;
boolean saveNow=false;

CrossingDetectEngine eng;


void setup() {
  size(800, 640);
  noFill();

  eng = new CrossingDetectEngine(this, WINSIZE);

  PGraphics ga=createGraphics(width, height, JAVA2D);
  ga.beginDraw();
  ga.rectMode(CORNERS);
  ga.stroke(255);
  ga.noFill();
  ga.strokeWeight(LINEWIDTH);
  ga.rect(0, 0, width/2, height/4);
  ga.rect(width/4, height/4, width*0.75, height*0.75);
  ga.rect(width/2, height/2, width*0.95, height*0.95);
  ga.endDraw();
  img = ga.get();
}

void draw() {
  background(0);
  image(img, 0, 0);
  loadPixels();


  if (execFilter1)   
    eng.showHit_v1a();

  if (execFilter2)   
    eng.showHit_v1b();    


  if (execFilter9) {
    execFilter9=false;
    noLoop();
    eng.showHit_v2(false);
    ArrayList<PVector> h=eng.getHit_v2();
    println("Hits found: "+h.size());
    for (int i=0; i<15&&i<h.size(); i++)
      println(h.get(i).toString());

    //saveFrame("####-frame.png");
  }

  if (saveNow) {
    saveFrame("####-frame.png");
    saveNow=false;
  }
}

void keyReleased() {

  if (key=='1') {
    execFilter2=execFilter9=false;
    execFilter1=!execFilter1;
  }

  if (key=='2') {
    execFilter1=execFilter9=false;
    execFilter2=!execFilter2;
  }

  if (key=='9') {
    execFilter1=execFilter2=false;
    execFilter9=!execFilter9;
  }

  if (key=='s')
    saveNow=true;

  if (execFilter1||execFilter2) noCursor();
  else cursor();

  if (!execFilter9) loop();
}