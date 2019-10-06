import processing.sound.*;
import beads.*;
import java.util.*;

PImage oof;

void setup(){
  //TODO: some shit here 
  size(460,461);
  oof = loadImage("th.jpg");
}

void draw(){
  loadPixels();
  oof.loadPixels();
  //DON'T FORGET TO AVOID NULL POINTER EXCEPTIONS 
  for(int x = 0; x < width-1; x++){
    for(int y = 0; y < height; y++){
      int loc = x+y*width;
      //flashlight effect 
      float r = red(oof.pixels[loc]);
      float b = blue(oof.pixels[loc]);
      float g = green(oof.pixels[loc]);
      float d = dist(mouseX, mouseY, x,y);
      float factor = map(d*2,0,200,2,0);
      pixels[loc] = color(r*factor, g*factor, b*factor);
      
      //allows brightness control  
      //float b = brightness(oof.pixels[loc]);
      //pixels[loc] = (b<mouseX)?color(255):color(0);
      
      //blurring functions with edge detection
      //blurring: making neighbouring pixels more similar by adding and 
      //averaging 
      //sharpening: making neighbouring pixels more different by subtracting
      //int loc1 = x + y*width;
      //int loc2 = (x+1) + y*width;
      //float b1 = oof.pixels[loc1];float b2 = oof.pixels[loc2];
      //float diff = abs(b1-b2);
      ////pixels[loc] = color(diff);
      //pixels[loc] = (diff>10)?color(255):color(0);
    }
  }
  updatePixels();
}
