import java.util.Arrays;
import java.util.Collections;


// Load an image from the data directory
// Load a different image by modifying the comments
PImage img; 
int[] hist, topVals;
void setup(){
  img = loadImage("test image 0.png");
  size(1734, 867);
  //img.filter(GRAY);
  hist = new int[256];
  topVals = new int[12];
  // Calculate the histogram
  image(img, 0, 0);
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      int bright = int(brightness(get(i, j)));
      hist[bright]++; 
    }
  }
  // Find the largest value in the histogram
  int histMax = max(hist);
  
  stroke(255);
  // Draw half of the histogram (skip every second value)
  for (int i = 0; i < img.width; i += 2) {
    // Map i (from 0..img.width) to a location in the histogram (0..255)
    int which = int(map(i, 0, img.width, 0, 255));
    // Convert the histogram value to a location between 
    // the bottom and the top of the picture
    int y = int(map(hist[which], 0, histMax, img.height, 0));
    line(i, img.height, i, y);
  }
  Arrays.sort(hist);
  for(int i = 0; i < topVals.length; i++){
    topVals[i] = hist[(hist.length - 1)-i];
    System.out.println(topVals[i]);
  }
}
void draw(){
}
