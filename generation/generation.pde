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
int chordCtr;
float[] freqs, amps;
int[] rhythms, topVals;
int note = 0;//index counts the notes 
int chord = 0;
float drumsRate;
boolean sharps;
Random rand = new Random();
void setup(){
  colorMode(HSB, 360, 100, 100);//selecting a HSB color model 
  triOsc = new TriOsc(this);
  env  = new Env(this);
  sharpChords = new SoundFile[14];
  flatChords = new SoundFile[14];
  usedChords = new SoundFile[14];
  for(int i = 0; i < usedChords.length; i++){
    sharpChords[i] = new SoundFile(this, "sharp Chord " + i + ".wav");
    flatChords[i] = new SoundFile(this, "flat Chord " + i + ".wav");
  }//for 
  
  //MAKE SURE THE HEIGHT IS 20 PX MORE THAN THE ACTUAL HEIGHT SO THAT THE COLOUR BAR CAN FIT ONTO THE SCREEN 
  size(571, 473);
  
  //hash table of histPart(key) : thatValue(value) pairs  
  img = loadImage("test1.png");
  //convert2Gray(img, 7);
  image(img,0,0);
  PImage brightImage = loadImage("test1.png");
  PImage satImage = loadImage("test1.png");
  PImage hueImage = loadImage("test1.png");
  int[] satHist = makeHist(satImage,1);//S
  int[] brightHist = makeHist(brightImage,2);//B
  int[] hueHist = makeHist(hueImage,0);//H
  System.out.println(Arrays.toString(hueHist));
  //Chord generation 
  int hmiBright = maxIndex(brightHist);
  //drum generation
  int hmiSat = maxIndex(satHist);
  drumsRate = map(hmiSat, 0, 100, 0.67, 1.33);
  System.out.println("drumsRate = " + drumsRate);
  drums = new SoundFile(this, "medium drum pattern.wav");
  drums.loop(drumsRate);
  //for(int i = 0; i < brightHist.length; i++){
  //  System.out.println("There are "+brightHist[i]+" pixels with brightness value "+i);
  //}
  PImage imgsharps = loadImage("test1.png");
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
  System.out.println("Saturation value with highest frequency is " + hmiSat);
  System.out.println("Brightness value with highest frequency is " + hmiBright);
  
  int[] topHues = topVals(hueHist, 7);//get top colours from hue histogram, try to use as melody notes 
  int[] melodyNotes = new int[topHues.length];
  //say topHues is {0,60,100,120,175,240,330}
  for(int i = 0; i < melodyNotes.length; i++){
    melodyNotes[i] = (int) map(topHues[i], 0, 360, 45, 75);
    System.out.println("melody notes[" + i + "] = " + melodyNotes[i]);
  }//for 
}//setup 

void draw(){
  //loadPixels();
  //img.loadPixels();
  // If value of trigger is equal to the computer clock and if not all 
  // notes have been played yet, the next note gets triggered.
  if (millis() > trigger) {
    if(chord == topChords.length){chord=0;}
    usedChords[topChords[chord]].play(1.0,1.0);
    chord++;
    trigger = (int) (millis() + (1/drumsRate)*2000);
  }
  //updatePixels();
}

int[] topVals(int[] arr, int num){
  int[] topArr = Arrays.copyOf(arr,arr.length);
  int[] topHues = new int[num];
  for(int i = 0; i < num; i++){
    int hmiHue = maxIndex(topArr);
    topHues[i] = hmiHue;
    topArr[hmiHue] = -1;
  }//for 
  System.out.println(Arrays.toString(topHues));
  return topHues;
}//topVals

int maxIndex(int[] arr){
  int max = 0; int maxInd = 0;
  for(int i = 0; i < arr.length; i++){
    if(arr[i] > max){max = arr[i]; maxInd = i;}
  }//for 
  return maxInd;
}//maxIndex

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
        System.out.println(hue);
        hist[hue]++;
      }
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
  }
  //updatePixels();
  return hist;
}//makeHist 

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
    }
  }
  int w = 0, bl = 0;
  for(int x = 0; x < width - 1; x++){
    for(int y = 0; y < height-20; y++){
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
