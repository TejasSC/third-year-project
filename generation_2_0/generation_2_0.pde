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
Textarea desc, satDesc, topHist, zeroHist, midHist, yAxis, topY, maxYhist, zeroFreq;
ControlFont font, fontS, fontD, numFont; PFont pfont;
String imageStr;
String audio = "audio/";
PImage img, displayImg, hueImg, satImg, brightImg, newSat;
AudioContext ac;
SoundFile[] sharpChords;
SoundFile[] flatChords;
SoundFile[] usedChords;
SoundFile[] melodyPhrases;
SoundFile drums;
int[] topChords, rhythms, topVals, pitches, hueHist, satHist, brightHist, newSatHist = null;
int chordTrigger = 0, noteTrigger = 0, note = 0, chord = 0;
int chordCtr, pitch;
float drumTime = 16000/3;
float drumsRate, drumBPM, firstDrumBPM;
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
  smooth();
  sharpChords = new SoundFile[14];
  flatChords = new SoundFile[14];
  usedChords = new SoundFile[14];

  /*
  Fonts for the UI
  */
  pfont = createFont("Helvetica",24,true);
  numFont = new ControlFont(pfont, 19);
  fontS = new ControlFont(pfont,16);
  font = new ControlFont(pfont,18);
  fontD = new ControlFont(pfont,21);

  /*
  prepare circle of 5ths of chords
  */
  for(int i = 0; i < usedChords.length; i++){
    sharpChords[i] = new SoundFile(this, audio+"sharp Chord " + i + ".wav");
    flatChords[i] = new SoundFile(this, audio+"flat Chord " + i + ".wav");
  }//for

  fullScreen();
  cp5 = new ControlP5(this);
  String prompt = "Click left buttons to view different histograms of ORIGINAL image\n"+
    "Click right buttons to load MORE images or EXIT";
  String satExtra = "Adjust knob then press button below to see real time graphical and musical effects";
  textFont(pfont);
  textSize(24);
  textAlign(CENTER);
  text(prompt, width/2, 45);
  cp5.addBang("hues")
    .setId(0)
    .setPosition(100,20)
    .setSize(100,50)
    .setFont(font)
    .setColorValue(color(66, 100, 100))
    .setColorActive(color(66, 100, 100))
    .setColorBackground(color(66, 100, 100))
    .setTriggerEvent(Bang.RELEASE);
  cp5.addBang("saturations")
    .setId(1)
    .setPosition(250,20)
    .setSize(100,50)
    .setFont(font)
    .setColorValue(color(66, 100, 100))
    .setColorActive(color(66, 100, 100))
    .setColorBackground(color(66, 100, 100))
    .setTriggerEvent(Bang.RELEASE);
  cp5.addBang("brightnesses")
    .setId(2)
    .setPosition(400,20)
    .setSize(100,50)
    .setFont(font)
    .setColorValue(color(66, 100, 100))
    .setColorActive(color(66, 100, 100))
    .setColorBackground(color(66, 100, 100))
    .setTriggerEvent(Bang.RELEASE);
  cp5.addBang("More images")
    .setId(3)
    .setPosition(width-400, 20)
    .setSize(100,50)
    .setFont(font)
    .setColorValue(color(150, 100, 100))
    .setColorActive(color(150, 100, 100))
    .setColorBackground(color(150, 100, 100))
    .setTriggerEvent(Bang.RELEASE);
  cp5.addBang("EXIT")
    .setId(4)
    .setPosition(width - 200, 20)
    .setSize(100,50)
    .setFont(font)
    .setColorValue(color(0, 100, 100))
    .setColorActive(color(0, 100, 100))
    .setColorBackground(color(0, 100, 100))
    .setTriggerEvent(Bang.RELEASE);
  satDesc = cp5.addTextarea("satDesc")
    .setPosition(width - 200, 120)
    .setSize(100,180)
    .setFont(fontS)
    .setColor(color(360))
    .setColorBackground(color(30))
    .setText(satExtra);
  cp5.addKnob("Drums speed \n(beats per minute)")
    .setId(5)
    .setPosition(width - 200, 320)
    .setSize(100,100)
    .setValue(firstDrumBPM)
    .setFont(fontS)
    .setRange(45,90);
  cp5.addBang("real time \nsaturations")
    .setId(6)
    .setPosition(width - 200, 500)
    .setSize(100,50)
    .setFont(font)
    .setColorValue(color(66, 100, 100))
    .setColorActive(color(66, 100, 100))
    .setColorBackground(color(66, 100, 100))
    .setTriggerEvent(Bang.RELEASE);
  desc = cp5.addTextarea("popUp")
    .setPosition(100, height - 75)
    .setSize((width - 200), 75)
    .setFont(fontD)
    .setColor(color(360))
    .setColorBackground(color(30));
  JButton open = new JButton();
  JFileChooser fc = new JFileChooser();
  String rootDir = "C:/Users/tscte/Desktop/Uni/2019-20/Third Year Project/generation_2_0/data";
  fc.setCurrentDirectory(new java.io.File(rootDir));
  String menuHeader = "Welcome! Select an image file (.jpg or .png)";
  fc.setDialogTitle(menuHeader);
  fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
  if(fc.showOpenDialog(open) == JFileChooser.APPROVE_OPTION){
    imgThere = true;
    imageStr = fc.getSelectedFile().getAbsolutePath();
    resume(imageStr);
  } else {System.exit(0);}//if
}//setup

public void controlEvent(ControlEvent theEvent){
  String content = ""; String thv = ""; String mhv = ""; String y = "";
  if(theEvent.getController().getName().equals("hues")){
    content = "Hue refers to the colours represented in the image.\n" +
      "Visualised as a rainbow spectrum,"+
      " colours through red, orange, yellow, green, blue and purple are"+
      " tracked as the hue value increases from 0 to 360.\nThe average hue" +
      " determines the instrument that plays as a melody over the drums"+
      " and chords. SCROLL DOWN to see more info on colour to instrument mappings:\n"+
      "Red to yellow: guitar\nYellow-green to very green: piano\n"+
      "Green-blue to purple-blue: sine wave\nPurple-blue to purple-pink: broken synth chords\n"+
      "purple-pink to red: trumpet";
    desc.setText(content);
    y = "How many pixels in the image with that hue value";
    yAxis.setText(y);
    mhv = "Hue value";
    thv = "360 (red again)";
    midHist.setText(mhv);
    topHist.setText(thv);
    zeroHist.setText("0 (red)");
    zeroFreq.setText("0");
    maxYhist.setText(Integer.toString(max(hueHist)));
    drawHist(hueHist, hueImg, 0);
  }//if
  if(theEvent.getController().getName().equals("saturations")){
    content = "Saturation refers to the intensity of a certain colour," +
      " distributed across a spectrum of wavelengths" +
      " e.g. highly saturated images will be very colourful but lowly" +
      " saturated images will have colour values closer to white, gray" +
      " or black.\n" + "The more saturated an image is, the faster the" +
      " speed of the drums.";
    desc.setText(content);
    y = "How many pixels in the image with that saturation value";
    mhv = "Saturation value";
    thv = "100 (highest)";
    yAxis.setText(y);
    midHist.setText(mhv);
    topHist.setText(thv);
    zeroHist.setText("0 (lowest)");
    zeroFreq.setText("0");
    maxYhist.setText(Integer.toString(max(satHist)));
    drawHist(satHist, satImg, 1);
  }//if
  if(theEvent.getController().getName().equals("brightnesses")){
    content = "Brightness refers to the general amount of light emitted" +
    " from an image. In this system, it is combined with other image processing" +
    " techniques and music theory ideas to generate the chord progression.";
    desc.setText(content);
    y = "How many pixels in the image with that brightness value";
    mhv = "Brightness value";
    thv = "100 (brightest)";
    yAxis.setText(y);
    midHist.setText(mhv);
    topHist.setText(thv);
    zeroHist.setText("0 (darkest)");
    zeroFreq.setText("0");
    maxYhist.setText(Integer.toString(max(brightHist)));
    drawHist(brightHist, brightImg, 2);
  }//if

  //Adjust the drum speed and also the saturation
  if(theEvent.getController().getId() == 5){
    drumsRate = map(theEvent.getController().getValue(), 45, 90, 0.5, 1);
    drums.stop();
    drums.loop(drumsRate);
    drumBPM = theEvent.getController().getValue();
  }//if

  //Actually display the image with edited saturation
  if(theEvent.getController().getId() == 6){
    newSat = loadImage(imageStr);
    for(int x = 0; x < newSat.width - 1; x++){
      for(int y_ = 0; y_ < newSat.height; y_++){
        int loc = y_*newSat.width + x;
        float h = hue(img.pixels[loc]);
        float b = brightness(img.pixels[loc]);
        float s = map(drumBPM, 45, 90, 0, 100);
        newSat.pixels[loc] = color(h, s, b);
      }//for
    }//for
    content = "Saturation refers to the intensity of a certain colour," +
      " distributed across a spectrum of wavelengths" +
      " e.g. highly saturated images will be very colourful but lowly" +
      " saturated images will have colour values closer to white, gray" +
      " or black.\n" + "The more saturated an image is, the faster the" +
      " speed of the drums.";
    desc.setText(content);
    y = "How many pixels in the image with that saturation value";
    mhv = "Saturation value";
    thv = "100 (highest)";
    yAxis.setText(y);
    midHist.setText(mhv);
    topHist.setText(thv);
    zeroFreq.setText("0");
    zeroHist.setText("0 (lowest)");
    newSatHist = makeHist(newSat, 1);
    maxYhist.setText(Integer.toString(max(newSatHist)));
    drawHist(newSatHist, newSat, 1);
  }//if

  if(theEvent.getController().getId() == 3){
    newSatHist = null;
    drums.play(1.0,0.0);
    drums.stop();
    setup();
  }//if
  if(theEvent.getController().getId() == 4){
    System.exit(0);
  }//if
}//controlEvent

void resume(String imageStr){
  System.out.println("resume method entered");
  //image display
  img = loadImage(imageStr);
  //copies of image for histogram generation
  hueImg = loadImage(imageStr);
  satImg = loadImage(imageStr);
  brightImg = loadImage(imageStr);
  
  image(img,100,100,img.width, img.height);
  
  cp5.addTextarea("yAxis")
   .setPosition(0, 100+img.height/2)
   .setSize(100,180)
   .setFont(new ControlFont(pfont,16))
   .setColor(color(360))
   .setColorBackground(color(0));
  
  cp5.addTextarea("maxYhist")
   .setPosition(10, 100)
   .setSize(90,180)
   .setFont(numFont)
   .setColor(color(360))
   .setColorBackground(color(0));
   
  cp5.addTextarea("zeroFreq")
   .setPosition(40, 75+img.height)
   .setSize(60,180)
   .setFont(numFont)
   .setColor(color(360))
   .setColorBackground(color(0));
  
  cp5.addTextarea("zeroHist")
   .setPosition(90, 105+img.height)
   .setSize(300, 40)
   .setFont(numFont)
   .setColor(color(360))
   .setColorBackground(color(0));
  
  cp5.addTextarea("midHist")
   .setPosition(90+img.width/2, 105+img.height)
   .setSize(200, 40)
   .setFont(numFont)
   .setColor(color(360))
   .setColorBackground(color(0));
  
  cp5.addTextarea("topHist")
   .setPosition(87+img.width, 105+img.height)
   .setSize(300, 40)
   .setFont(numFont)
   .setColor(color(360))
   .setColorBackground(color(0));
  
  /*
  histograms generation
  */
  hueHist = makeHist(hueImg,0);//H
  satHist = makeHist(satImg,1);//S
  brightHist = makeHist(brightImg,2);//B

  /*
  drum generations
  */
  int hmiSat = maxIndex(satHist);
  drumsRate = map(hmiSat, 0, 100, 0.5, 1.0);
  firstDrumBPM = map(hmiSat, 0, 100, 45, 90);
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
  //System.out.println(Arrays.toString(topHues));
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
  melodyPhrases = getNotes(sharps, topChords, avg);
}//resume

void draw(){
  if(imgThere){
    if (millis() > chordTrigger) {
      if(chord == topChords.length){chord=0;}
      chord = (int)random(0,topChords.length);
      usedChords[topChords[chord]].play(1.0,0.75);
      chordTrigger = (int) (millis() + 2000);
    }//if
    if(millis() > noteTrigger){
      melodyPhrases[0].play(1.0, 0.9);
      noteTrigger = (int) (millis() + 2000);
    }//if
  }//imgThere
}//draw

/*
Function to get melody instrument based off of most common hue in picture
*/
SoundFile[] getNotes(boolean sharps, int[] topChords, int avg){
  SoundFile[] phrases = new SoundFile[1];
  int ctr;
  if(topChords.length == 2){ctr = topChords[0];}else{ctr = topChords[2];}
  int pair = ctr/2;
  String melodies = "melodies/"; String tonality = ""; String instrument = "";
  if(sharps){tonality += "sharp Chord/";}else{tonality += "flat Chord/";}
  switch(avg/72){
    case 0: instrument += "guitar"; break;
    case 1: instrument += "piano"; break;
    case 2: instrument += "sine"; break;
    case 3: instrument += "synth"; break;
    default:instrument += "trumpet"; break;
  }//switch
  String path = audio+melodies + tonality + pair + "/" + instrument + "/0.wav";
  phrases[0] = new SoundFile(this, path);
  return phrases;
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
        //Brighness is the amount of light, ranging between 0 and 100
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
  image(img, 100,100,img.width, img.height);
}//drawHist

/*
Uses binary thresholding to determine which side of the circle of 5ths chords will come from
*/
boolean tonality(PImage img, int thresh){
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

/*
Calculates average value of a numerical array
*/
float average(int[] arr){
  float avg = 0.0; float sum = 0.0;
  for (int i:arr){sum+=i;}//for
  avg = sum/arr.length;
  return avg;
}//average
