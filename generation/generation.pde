import processing.sound.*;
import beads.*;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import static java.util.Map.Entry;
import java.util.LinkedHashMap;
import controlP5.*;

ControlP5 cp5;

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

// Set the note trigger
int chordTrigger = 0, noteTrigger = 0; 
int chordCtr;
float[] freqs, amps;
int[] rhythms, topVals, melodyNotes;
int note = 0;//index counts the notes 
int chord = 0;
float drumsRate;
boolean sharps;
Random rand = new Random();
void setup(){
  /*
  selecting a HSB color model
  */
  colorMode(HSB, 360, 100, 100); 
  triOsc = new TriOsc(this);
  env  = new Env(this);
  sharpChords = new SoundFile[14];
  flatChords = new SoundFile[14];
  usedChords = new SoundFile[14];
  
  /*
  prepare circle of 5ths of chords 
  */
  for(int i = 0; i < usedChords.length; i++){
    sharpChords[i] = new SoundFile(this, "sharp Chord " + i + ".wav");
    flatChords[i] = new SoundFile(this, "flat Chord " + i + ".wav");
  }//for 
  
  //MAKE SURE THE HEIGHT IS 20 PX MORE THAN THE ACTUAL HEIGHT SO THAT THE COLOUR BAR CAN FIT ONTO THE SCREEN 
  size(492, 507);
  
  cp5 = new ControlP5(this);
  cp5.addButton("select an image");
  String str = "rainbow crop.jpg";
  
  //image display   
  img = loadImage(str);
  image(img,0,0);
  
  /*
  histogram time
  */
  PImage brightImage = loadImage(str);
  PImage satImage = loadImage(str);
  PImage hueImage = loadImage(str);
  int[] satHist = makeHist(satImage,1);//S
  int[] brightHist = makeHist(brightImage,2);//B
  int[] hueHist = makeHist(hueImage,0);//H
  
  /*
  drum generation
  */
  int hmiSat = maxIndex(satHist);
  drumsRate = map(hmiSat, 0, 100, 0.67, 1.33);
  System.out.println("drumsRate = " + drumsRate);
  drums = new SoundFile(this, "medium drum pattern.wav");
  drums.loop(drumsRate);
  
  
  /*
  Chord generation
  */ 
  int hmiBright = maxIndex(brightHist);
  PImage imgsharps = loadImage(str);
  //performs binary thresholding to decide whether sharps or flats 
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
  chordCtr = 13 - (int)map(hmiBright,0,100,0,13);
  if(chordCtr % 13 == 0){
    //if key chord is c major or Eb minor, just repeat that with its relative majors and minors 
    topChords = new int[2];
    if(chordCtr == 0){topChords[0]=0;topChords[1]=1;}
    else{topChords[0]=12;topChords[1]=13;}
  } else {
    topChords = new int[3];
    topChords[0] = chordCtr - 1;
    topChords[1] = chordCtr;
    topChords[2] = chordCtr + 1;
  }//if 
  System.out.println("length of topChords = " + topChords.length);
  for(int j = 0; j < topChords.length; j++){
    System.out.println("chord " + topChords[j]);
  }//for
  
  /*
  melody generation
  */ 
  int[] topHues = topVals(hueHist, 7);//get top colours from hue histogram, try to use as melody notes 
  melodyNotes = new int[topHues.length];
  //say topHues is {0,60,100,120,175,240,330}
  for(int i = 0; i < melodyNotes.length; i++){
    melodyNotes[i] = (int) map(topHues[i], 0, 360, 55, 75);
  }//for 
}//setup 

void draw(){
  //loadPixels();
  //img.loadPixels();
  // If value of trigger is equal to the computer clock and if not all 
  // notes have been played yet, the next note gets triggered.
  if (millis() > chordTrigger) {
    if(chord == topChords.length){chord=0;}
    usedChords[topChords[chord]].play(1.0,1.0);
    chord++;
    chordTrigger = (int) (millis() + (1/drumsRate)*2000);
  }//if 
  if(millis() > noteTrigger){
    // midiToFreq transforms the MIDI value into a frequency in Hz which we use 
    //to control the triangle oscillator with an amplitute of 0.8
    if (note == melodyNotes.length) {note = 0;}
    triOsc.play(midiToFreq(melodyNotes[note]), 0.8);
    // The envelope gets triggered with the oscillator as input and the times and 
    // levels we defined earlier   
    env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    note++; 
    noteTrigger = (int) (millis() + (1/(6*drumsRate))*2000);
  }//if 
  //updatePixels();
}//draw 

/*
Function to get indexes of top 'num' values from array  'arr'
*/
int[] topVals(int[] arr, int num){
  int[] topArr = Arrays.copyOf(arr,arr.length);
  int[] topHues = new int[num];
  for(int i = 0; i < num; i++){
    int hmiHue = maxIndex(topArr);
    topHues[i] = hmiHue;
    topArr[hmiHue] = -1;
  }//for 
  //System.out.println(Arrays.toString(topHues));
  return topHues;
}//topVals

/*
Finds the index of maximum element in array 
*/
int maxIndex(int[] arr){
  int max = 0; int maxInd = 0;
  for(int i = 0; i < arr.length; i++){
    if(arr[i] > max){max = arr[i]; maxInd = i;}
  }//for 
  return maxInd;
}//maxIndex

/*
Constructs histogram for hue, saturation or brightness 
*/
int[] makeHist(PImage img, int choice){
  //loadPixels();
  int[] hist;
  if(choice == 0){
    hist = new int[360];//hue 
    //draw the line at the bottom of the image, representing hue values from 0 to 360
    for(int i = 0; i < width; i++){
      int c = (int) map(i, 0, width, 0, 360);
      stroke(c,100,100);
      rect(i, height - 20, 1, 20);
    }//for 
  } else {
    hist = new int[101];//saturation, brightness 
  }//if
  
  
  // Calculate the histogram
  for (int x = 0; x < width - 1; x++) {
    for (int y = 0; y < height-20; y++) {
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
      }//if 
    }//for 
  }//for 
  
  // Find the largest value in the histogram
  int histMax = max(hist);
  // Draw half of the histogram (skip every second value)
  int scale;
  
  for (int i = 0; i < width; i ++) {
    int c;
    if(choice == 0){
      c = (int) map(i, 0, width, 0, 360);
      stroke(c,100,100);//H
    } else if (choice == 1) {
      c = (int) map(i, 0, width, 0, 100);
      stroke(360, c, 100);//S
    } else {
      c = (int) map(i, 0, width, 0, 100);
      c = (int) map(c, 0, 100, 0, 360);
      stroke(c);//B
    }//if 
    // Map i (from 0..img.width) to a location in the histogram (0..255)
    if(choice == 0){
      scale = 359;//hue 
    } else {
      scale = 101;//saturation, brightness 
    }//if
    int which = int(map(i, 0, width, 0, scale));
    // Convert the histogram value to a location between 
    // the bottom and the top of the picture
    int y = int(map(hist[which], 0, histMax, height-20, 0));
    line(i, height-20, i, y);
  }//for 
  //updatePixels();
  return hist;
}//makeHist 

/*
Uses binary thresholding to determine which side of the circle of 5ths chords will come from 
*/
boolean tonality(PImage img, int thresh){
  loadPixels();
  color white = color(0,0,100);
  color black = color(0,0,0);
  float r,g,b,gray;
  for(int x = 0; x < width - 1; x++){
    for(int y = 0; y < height-20; y++){
      int loc = y*width + x;
      r = red(pixels[loc]);
      b = blue(pixels[loc]);
      g = green(pixels[loc]);
      gray = getGray(r,g,b,1);
      color c = gray < thresh ? black : white;
      pixels[loc] = c;
    }//for 
  }//for 
  int w = 0, bl = 0;
  for(int x = 0; x < width - 1; x++){
    for(int y = 0; y < height-20; y++){
      int loc = y*width + x;
      if(pixels[loc] == white){
        w++;
      } else {
        bl++;
      }//if
    }//for 
  }//for 
  println("Black: " + bl);
  println("White: " + w);
  //updatePixels();
  return w > bl; 
}//tonality 

/*
Many ways to covert an image to grayscale 
*/
void convert2Gray(PImage img, int way){
  if (way >= 4){
    img.filter(GRAY);
  } else {
    float gray, r, g, b;
    for(int x = 0; x < width - 1; x++){
      for(int y = 0; y < height-20; y++){
        int loc = x+y*width;
        r = red(img.pixels[loc]);
        b = blue(img.pixels[loc]);
        g = green(img.pixels[loc]);
        gray = getGray(r,g,b,way);
        img.pixels[loc] = color(int(gray));
      }//for 
    }//for
  }//if 
}//convert2Gray 

/*
Luminanace: physically, the luminous intensity per unit area of light 
- measures light "intensity"
Relative luminance = how "intense" a light appears to a human 
Luma = relative luminance calculation, based on a gamma-compressed video signal
*/
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
}//getGray 

/* 
This function calculates the respective frequency of a MIDI note
*/
float midiToFreq(int note) {
  return (pow(2, ((note-69)/12.0)))*440;
}//midiToFreq
