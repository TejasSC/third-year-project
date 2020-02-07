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
import javax.swing.JFileChooser;
import javax.swing.JButton;
import java.io.File;

/*
All the variables I need
*/
ControlP5 cp5;
String imageStr;
String audio = "audio/";
PImage img, hueImg, satImg, brightImg;
AudioContext ac;
// Times and levels for the ASR envelope
float attackTime = 0.004;
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
int chordCtr, pitch;
float[] freqs, amps;
int[] rhythms, topVals, midiNotes, pitches, hueHist, satHist, brightHist;
int note = 0;//index counts the notes 
int chord = 0;
float drumsRate;
boolean sharps, hueToggle, satToggle, brightToggle, imgThere;
Random rand = new Random();

/*
Setup time 
*/
void setup(){
  imageMode(CORNER);
  hueToggle = satToggle = brightToggle = imgThere = false;
  /*
  selecting a HSB color model
  */
  colorMode(HSB, 360, 100, 100);
  background(0);
  triOsc = new TriOsc(this);
  env  = new Env(this);
  sharpChords = new SoundFile[14];
  flatChords = new SoundFile[14];
  usedChords = new SoundFile[14];
  
  PFont pfont = createFont("Arial",20,true);
  ControlFont font = new ControlFont(pfont,18);
  
  /*
  prepare circle of 5ths of chords 
  */
  for(int i = 0; i < usedChords.length; i++){
    sharpChords[i] = new SoundFile(this, audio+"sharp Chord " + i + ".wav");
    flatChords[i] = new SoundFile(this, audio+"flat Chord " + i + ".wav");
  }//for 
  
  //MAKE SURE THE img.height IS 20 PX MORE THAN THE ACTUAL img.height SO THAT THE COLOUR BAR CAN FIT ONTO THE SCREEN 
  size(2160, 1080);
  //fullScreen();
  cp5 = new ControlP5(this);
  cp5.addBang("hues")
    .setId(0)
    .setPosition(100,25)
    .setSize(100,50)
    .setFont(font)
    .setTriggerEvent(Bang.RELEASE);
  cp5.addBang("saturations")
    .setId(1)
    .setPosition(250,25)
    .setSize(100,50)
    .setFont(font)
    .setTriggerEvent(Bang.RELEASE);
  cp5.addBang("brightnesses")
    .setId(2)
    .setPosition(400,25)
    .setSize(100,50)
    .setFont(font)
    .setTriggerEvent(Bang.RELEASE);
  JButton open = new JButton();
  JFileChooser fc = new JFileChooser();
  String rootDir = "C:/Users/tscte/Desktop/Uni/2019-20/Third Year Project/generation/data";
  fc.setCurrentDirectory(new java.io.File(rootDir));
  fc.setDialogTitle("Select an image file (.jpg or .png)");
  fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
  if(fc.showOpenDialog(open) == JFileChooser.APPROVE_OPTION){
    imgThere = true;
  }//if 
  imageStr = fc.getSelectedFile().getAbsolutePath();
  //imageStr = cp5.get(Textfield.class,"Type the name of an image file here").getText();
  //imgThere = true;
  crackOn(imageStr);
}//setup 

void hues(){
  hueToggle = !hueToggle;
}//hues

void saturations(){
  satToggle = !satToggle;
}//saturations

void brightnesses(){
  brightToggle = !brightToggle;
}//brightness

public void controlEvent(ControlEvent theEvent){
  if(theEvent.getController().getName().equals("hues")){
    drawHist(hueHist, hueImg, 0); 
  }//if
  if(theEvent.getController().getName().equals("saturations")){
    drawHist(satHist, satImg, 1); 
  }//if 
  if(theEvent.getController().getName().equals("brightnesses")){
    drawHist(brightHist, brightImg, 2); 
  }//if 
}//controlEvent

void crackOn(String imageStr){
  //image display   
  img = loadImage(imageStr);
  hueImg = loadImage(imageStr);
  satImg = loadImage(imageStr);
  brightImg = loadImage(imageStr);
  image(img, 100,100,img.width, img.height);
  
  /*
  histograms generation 
  */
  PImage brightImage = loadImage(imageStr);
  PImage satImage = loadImage(imageStr);
  PImage hueImage = loadImage(imageStr);
  hueHist = makeHist(hueImage,0);//H
  satHist = makeHist(satImage,1);//S
  brightHist = makeHist(brightImage,2);//B
  
  /*
  drum generation
  */
  int hmiSat = maxIndex(satHist);
  drumsRate = map(hmiSat, 0, 100, 0.67, 1.33);
  //System.out.println("drumsRate = " + drumsRate);
  
  drums = new SoundFile(this, audio+"medium drum pattern.wav");
  drums.loop(drumsRate);
  
  /*
  Chord generation
  */ 
  int hmiBright = maxIndex(brightHist);
  PImage imgsharps = loadImage(imageStr);
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
  /*
  melody generation
  */ 
  int[] topHues = topVals(hueHist, 7);
  System.out.println(Arrays.toString(topHues));
  int avg = (int)average(topHues);
  
  chordCtr = 13 - (int)map(hmiBright,0,100,0,13);
  //chordCtr = (int)map(avg, 0, 360, 0, 13);
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
  midiNotes = getNotes(sharps, topChords);
}//crackOn

void draw(){
  if (imgThere){
    if (millis() > chordTrigger) {
      if(chord == topChords.length){chord=0;}
      chord = (int)random(0,topChords.length);
      usedChords[topChords[chord]].play(1.0,0.7);
      chordTrigger = (int) (millis() + (1/drumsRate)*2000);
    }//if
    if(millis() > noteTrigger){
      // midiToFreq transforms the MIDI value into a frequency in Hz which we use 
      //to control the triangle oscillator with an amplitute of 0.8
      note = (int)random(0,midiNotes.length);
      triOsc.play(Pitch.mtof(midiNotes[note]), 0.6);
      // The envelope gets triggered with the oscillator as input and the times and 
      // levels we defined earlier   
      env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
      noteTrigger = (int) (millis() + (1/(4*drumsRate))*2000);
    }//if 
  }//imgThere 
}//draw 

/*
Function to get note of scale based on chord centre and note from hue 
*/
int[] getNotes(boolean sharps, int[] topChords){
  int[] scale = new int[5];
  int ctr;
  if(topChords.length == 2){ctr = topChords[0];}else{ctr = topChords[2];}
  int x;// decides root note of the scale 
  if(sharps){
    switch(ctr){
      case 0: x = 72; break;
      case 1: x = 72; break;
      case 2: x = 79; break;
      case 3: x = 79; break;
      case 4: x = 74; break;
      case 5: x = 74; break;
      case 6: x = 81; break;
      case 7: x = 81; break;
      case 8: x = 76; break;
      case 9: x = 76; break;
      case 10: x = 83; break;
      case 11: x = 83; break;
      case 12: x = 78; break;
      case 13: x = 78; break;
      default: x = 72;
    }//switch 
  } else {
    switch(ctr){
      case 0: x = 72; break;
      case 1: x = 72; break;
      case 2: x = 77; break;
      case 3: x = 77; break;
      case 4: x = 82; break;
      case 5: x = 82; break;
      case 6: x = 75; break;
      case 7: x = 75; break;
      case 8: x = 80; break;
      case 9: x = 80; break;
      case 10: x = 73; break;
      case 11: x = 73; break;
      case 12: x = 78; break;
      case 13: x = 78; break;
      default: x = 72;
    }//switch 
  }//if 
  //make pentatonic scale based on what note x is 
  for(int i = 0; i < scale.length; i++){
    if(i < 3){
      scale[i] = x + 2*i;
    }else{
      scale[i] = x + (2*i + 1);
    }//if 
  }//for
  return scale;
}//getNote

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
  int offset = 100;
  int[] hist;
  if(choice == 0){
    hist = new int[360];//hue 
  } else {
    hist = new int[101];//saturation, brightness 
  }//if
  
  
  // Calculate the histogram
  for (int x = 0; x < img.width - 1; x++) {
    for (int y = 0; y < img.height-20; y++) {
      int loc = x+y*img.width;
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
  return hist;
}//makeHist 

void drawHist(int[] hist, PImage img, int choice){
  imageMode(CORNER);
  image(img, 100,100,img.width, img.height);
  int offset = 100;
  // Find the largest value in the histogram
  int histMax = max(hist);
  // Draw half of the histogram (skip every second value)
  int scale;
  for (int i = 0; i < img.width; i ++) {
    int c;
    if(choice == 0){
      c = (int) map(i, 0, img.width, 0, 360);
      stroke(c,100,100);//H
      rect(offset+i, offset+img.height - 20, 1, 20);
    } else if (choice == 1) {
      c = (int) map(i, 0, img.width, 0, 100);
      stroke(360, c, 100);//S
    } else {
      c = (int) map(i, 0, img.width, 0, 100);
      c = (int) map(c, 0, 100, 0, 360);
      stroke(c);//B
    }//if 
    // Map i (from 0..img.img.width) to a location in the histogram (0..255)
    if(choice == 0){
      scale = 359;//hue 
    } else {
      scale = 101;//saturation, brightness 
    }//if
    int which = int(map(i, 0, img.width, 0, scale));
    // Convert the histogram value to a location between 
    // the bottom and the top of the picture
    int y = int(map(hist[which], 0, histMax, img.height, 0));
    line(offset+i, offset+img.height, offset+i, offset+y);
  }//for 
}//drawHist

/*
Uses binary thresholding to determine which side of the circle of 5ths chords will come from 
*/
boolean tonality(PImage img, int thresh){
  //loadPixels();
  color white = color(0,0,100);
  color black = color(0,0,0);
  float r,g,b,gray;
  for(int x = 0; x < img.width - 1; x++){
    for(int y = 0; y < img.height-20; y++){
      int loc = y*img.width + x;
      r = red(img.pixels[loc]);
      b = blue(img.pixels[loc]);
      g = green(img.pixels[loc]);
      gray = getGray(r,g,b,1);
      color c = gray < thresh ? black : white;
      img.pixels[loc] = c;
    }//for 
  }//for 
  int w = 0, bl = 0;
  for(int x = 0; x < img.width - 1; x++){
    for(int y = 0; y < img.height-20; y++){
      int loc = y*img.width + x;
      if(img.pixels[loc] == white){
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
    for(int x = 0; x < img.width - 1; x++){
      for(int y = 0; y < img.height-20; y++){
        int loc = x+y*img.width;
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

float average(int[] arr){
  float avg = 0.0; float sum = 0.0;
  for (int i:arr){sum+=i;}//for
  avg = sum/arr.length;
  return avg;
}//average
