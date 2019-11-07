PShape mask;
PImage llama;

void setup() {
  size(600, 600, P2D);
  noFill();

  // create circular "mask" to draw over animation
  pushStyle();
  fill(256, 256, 256);
  noStroke();

  frameRate(12);

  mask = createShape();
  mask.beginShape();

  mask.vertex(0, 0);
  mask.vertex(width, 0);
  mask.vertex(width, height);
  mask.vertex(0, height);

  mask.beginContour();
  for (int i = 360; i > 0; i--) {
    mask.vertex(
      width/2 + cos(radians(i)) * width/2, 
      height/2 + sin(radians(i)) * height/2
      );
  }
  mask.endContour();
  mask.endShape(CLOSE);
  popStyle();

  llama = loadImage("llama2.png");
}

int index (int x, int y, int w) {
  return y * w + x;
}

int getBWPixelValue (int x, int y, int w) {
  return pixels[index(x, y, w)] >> 16 & 0xFF; // all three channels are the same anyway
} 

void draw() {
  background(256, 256, 256);
  image(llama, 0, 0);
  loadPixels();
  background(256, 256, 256);

  float step = 6;
  int yoff = int(frameCount % step); // animate the lines
  float lightness;
  float angle;
  float y;
  float freq;
  float maxFreq = sin(radians(frameCount % 360)) * 4; // oscillated the range of freq values
  for (int k = 0; k < height; k += step) {
    beginShape();
    for (int i = 0; i < width; i+=step) {
      lightness = (float)getBWPixelValue(i, k + yoff, width);
      freq = round(maxFreq - (lightness/255) * maxFreq);
      for (float j = 0; j < step; j++) {
        angle = j/step * TWO_PI;
        y = sin(angle * freq) * step/2;
        vertex(i + j, k + y + yoff);
      }
    }
    endShape();
  }
  
  shape(mask);
  
  saveFrame("output/frame-###.png");
  if (frameCount >= 180) exit();
}
