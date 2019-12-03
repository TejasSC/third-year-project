//binary thresholding implementaiton 
PImage img;

void setup(){
  img = loadImage("test image 0.png");
  size(1734,867);
  img.filter(THRESHOLD);
  image(img, 0,0);
  loadPixels();
  int black = 0, white = 0;
  for(int x = 0; x < width - 1; x++){
    for(int y = 0; y < height; y++){
      int loc = y*width + x;
      if(red(pixels[loc])==0 && green(pixels[loc])==0 && blue(pixels[loc])==0){
        //below threshold, increase count of black
        black++;
      } else {
        white++;
      }
      System.out.println("pixels[loc] = " + img.pixels[loc]);
    }
  }
  println("Black: " + black);
  println("White: " + white);
}
void draw(){
  
}
