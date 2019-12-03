import processing.sound.*;
import beads.*;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import static java.util.Map.Entry;
import java.util.LinkedHashMap;

PImage img;
AudioContext ac;
// Times and levels for the ASR envelope
float attackTime = 0.001;
float sustainTime = 0.002;
float sustainLevel = 0.4;
float releaseTime = 0.2;
//int[] hist, topVals, localMaxima;
SoundFile[] sharpChords;
SoundFile[] flatChords; 
SoundFile[] usedChords;
int[] topChords;
SoundFile drums;
// Oscillator and envelope 
TriOsc triOsc;
Env env; 

// Set the duration between the notes
//int duration = 400;
// Set the note trigger
int trigger = 0; 
float[] freqs, amps;
int[] rhythms, topVals;
int note = 0;//index counts the notes 
int chord = 0;
boolean sharps;
void setup(){
  colorMode(HSB, 360, 100, 100);//selecting a HSB color model 
  triOsc = new TriOsc(this);
  env  = new Env(this);
  sharpChords = new SoundFile[14];
  flatChords = new SoundFile[14];
  usedChords = new SoundFile[14];
  //drums = new SoundFile(this, "drum pattern.wav");
  //drums.loop(1,0.0,0.7,0);
  for(int i = 0; i < usedChords.length; i++){
    sharpChords[i] = new SoundFile(this, "sharp Chord " + i + ".wav");
    flatChords[i] = new SoundFile(this, "flat Chord " + i + ".wav");
  }
  size(460, 461);
  //hash table of histPart(key) : thatValue(value) pairs  
  img = loadImage("th.jpg");
  //convert2Gray(img, 7);
  image(img,0,0);
  PImage histImage = loadImage("test image 0.png");
  //int[] hist = makeHist(histImage,0);//H
  int[] hist = makeHist(histImage,1);//S
  //int[] hist = makeHist(histImage,2);//B
  topChords = new int[4];
  //for(int i = 0; i < hist.length; i++){
  //  System.out.println("There are "+hist[i]+" pixels with brightness value "+i);
  //}
  PImage imgsharps = loadImage("test image 4.png");
  //performs binary thresholding to decide whether 
  sharps = tonality(imgsharps, 50);
  if(sharps){
    for(int i = 0; i < sharpChords.length; i++){
      usedChords[i] = sharpChords[i];
    }//for 
  } else {
    for(int i = 0; i < flatChords.length; i++){
      usedChords[i] = flatChords[i];
    }//for 
  }//if 
  
}

void draw(){
  loadPixels();
  img.loadPixels();
  // If value of trigger is equal to the computer clock and if not all 
  // notes have been played yet, the next note gets triggered.
  if (millis() > trigger) {
    int chord = (int)random(0,13);
    usedChords[chord].play(1.0,1.0);
    //// frequency in hz, with amplitude value of pixel (note) 
    ////to control the triangle oscillator with an amplitute of 0.8
    //triOsc.play(freqs[note],amps[note]);
    //// The envelope gets triggered with the oscillator as input and the times and 
    //// levels we defined earlier
    //env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    
    //trigger = millis() + rhythms[note];
    //note++;//move along to next pixel/note
    trigger = millis()+1900;
  }
  updatePixels();
}

int[] makeHist(PImage img, int choice){
  int[] hist;
  if(choice == 0){
    hist = new int[360];//hue 
  } else {
    hist = new int[101];//saturation, brightness 
  }//if
  
  
  // Calculate the histogram
  for (int x = 0; x < width - 1; x++) {
    for (int y = 0; y < height; y++) {
      int loc = x+y*width;
      if(choice == 2){
        //Brighness is the amount of light, ranging between 0 and 100. The alpha channel goes from 0 (not visible) to 1 (fully opaque).
        int bright = int(brightness(img.pixels[loc]));
        hist[bright]++; 
      } else if (choice == 1){
        int sat = int(saturation(img.pixels[loc]));
        hist[sat]++;
      } else {
        int hue = int(hue(img.pixels[loc]));
        hist[hue]++;
      }
    }//for 
  }//for 
  
  // Find the largest value in the histogram
  int histMax = max(hist);
  int value = 255;
  stroke(value);//hue will be represented with black lines, saturation with gray lines, brightness with white lines 
  // Draw half of the histogram (skip every second value)
  int scale;
  for (int i = 0; i < width; i ++) {
    // Map i (from 0..img.width) to a location in the histogram (0..255)
    if(choice == 0){
      scale = 359;//hue 
    } else {
      scale = 101;//saturation, brightness 
    }//if
    int which = int(map(i, 0, width, 0, scale));
    // Convert the histogram value to a location between 
    // the bottom and the top of the picture
    int y = int(map(hist[which], 0, histMax, height, 0));
    line(i, height, i, y);
  }
  return hist;
}//makeHist 

boolean tonality(PImage img, int thresh){
  loadPixels();
  color white = color(0,0,100);
  color black = color(0,0,0);
  float r,g,b,gray;
  for(int x = 0; x < width - 1; x++){
    for(int y = 0; y < height; y++){
      int loc = y*width + x;
      r = red(pixels[loc]);
      b = blue(pixels[loc]);
      g = green(pixels[loc]);
      gray = getGray(r,g,b,1);
      color c = gray < thresh ? black : white;
      pixels[loc] = c;
    }
  }
  int w = 0, bl = 0;
  for(int x = 0; x < width - 1; x++){
    for(int y = 0; y < height; y++){
      int loc = y*width + x;
      if(pixels[loc] == white){
        w++;
      } else {
        bl++;
      }
    }
  }
  println("Black: " + bl);
  println("White: " + w);
  //updatePixels();
  return w > bl; 
}

void convert2Gray(PImage img, int way){
  if (way >= 4){
    img.filter(GRAY);
  } else {
    float gray, r, g, b;
    for(int x = 0; x < width - 1; x++){
      for(int y = 0; y < height; y++){
        int loc = x+y*width;
        r = red(img.pixels[loc]);
        b = blue(img.pixels[loc]);
        g = green(img.pixels[loc]);
        gray = getGray(r,g,b,way);
        img.pixels[loc] = color(int(gray));
      }//for 
    }//for
  }//if 
}

//Luminanace: physically, the luminous intensity per unit area of light 
//-- measures light "intensity"
//Relative luminance = how "intense" a light appears to a human 
//Luma = relative luminance calculation, based on a gamma-compressed video signal
float getGray(float r, float g, float b, int way){
  if(way == 0){
    //average
    return (r+g+b)/3;
  } else if (way == 1){
    //linear luminance, as used by standard colour TV and video systems e.g. PAL, NTSC
    return 0.299*r + 0.587*g + 0.114*b;
  } else if (way == 2){
    //ITU-R BT.709 standard used for HDTV systems 
    return 0.2126*r + 0.7152*g + 0.0722*b;
  } else if (way == 3){
    //ITU-R BT.2100 standard for HDR television
    return 0.2627*r + 0.678*g + 0.0593*b; 
  } else {
    return 0.0;
  }//if 
}

// This function calculates the respective frequency of a MIDI note
float midiToFreq(int note) {
  return (pow(2, ((note-69)/12.0)))*440;
}
