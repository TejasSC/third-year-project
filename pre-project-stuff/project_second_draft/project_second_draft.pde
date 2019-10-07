import processing.sound.*;
import beads.*;
import java.util.*;

PImage img;
PImage oof;
PImage[] images = new PImage[5];
Bubble[] bubbles = new Bubble[8];

//downsample images if working with a lot, so that program runs smoother 
void setup(){
  size(1000,800);
  for (int i = 0; i < images.length; i++){
    images[i] = loadImage("test image "+i+".jpg");
  }
  for (int i = 0; i < bubbles.length; i++){
    int j = int(random(0, images.length-1));//random value adding 
    bubbles[i] = new Bubble(100*(1+i), height, random(32,72), images[j]);
  }
}


void draw(){
  background(0);
  //tint(255,0,0);
  for (int i = 0; i < bubbles.length; i++){
    bubbles[i].goUp();
    bubbles[i].display(i);
    bubbles[i].top();
  }
}
