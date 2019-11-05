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
SoundFile[] chords, usedChords;
SoundFile drums;
// Oscillator and envelope 
TriOsc triOsc;
Env env; 

// Set the duration between the notes
//int duration = 400;
// Set the note trigger
int trigger = 0; 
float[] freqs, amps;
int[] rhythms;
int note = 0;//index counts the notes 
void setup(){
  triOsc = new TriOsc(this);
  env  = new Env(this);
  //TODO
  //size(460,461);
  //oof = loadImage("th.jpg");
  chords = new SoundFile[12]; usedChords = new SoundFile[5];
  drums = new SoundFile(this, "drum pattern.wav");
  drums.loop(1,0.0,0.7,0);
  //for(int i = 0; i < chords.length; i++){
  //  chords[i] = new SoundFile(this, "Chord " + i + ".mp3");
  //}
  //ac = new AudioContext();
  size(178, 76);
  img = loadImage("car.png");
  image(img,0,0);
  convert2Gray(img, 2);
  image(img,0,0);
  //store the notes in an array
  freqs = new float[height * width];
  amps = new float[height * width];
  rhythms = new int[height * width];
  for(int y = 0; y < height; y++){
    print(y+"\n");
    for(int x = 0; x < width - 1; x++){
      int loc = x+y*width;
      float r = red(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      //float l = brightness(pixels[loc]);
      //calculate rhythmic values = semiquaver, quaver or crotchet
      //reds of lower values are longer notes, higher values are shorter notes
      int rhythm;
      if(r < 63.0){
        rhythm = 500;
      } else if (r >= 63.0 && r < 127.0){
        rhythm = 250;
      } else {
        rhythm = 125;
      }
      //Amplitude determined via how much green there is 
      float loudness = map(g, 0, 255, 0.2, 0.8);
      //Actual note determined by how much blue there is 
      int note = int(map(b, 0, 255, 50, 80));
      note = Pitch.forceToScale(note, Pitch.dorian);
      float freq = midiToFreq(note);
      freqs[loc] = freq;
      amps[loc] = loudness;
      rhythms[loc] = rhythm;
    }
  }
}

void draw(){
  loadPixels();
  img.loadPixels();
  print("pixel "+note+"\n");
  // If value of trigger is equal to the computer clock and if not all 
  // notes have been played yet, the next note gets triggered.
  if ((millis() > trigger) && (note<freqs.length)) {
    // frequency in hz, with amplitude value of pixel (note) 
    //to control the triangle oscillator with an amplitute of 0.8
    triOsc.play(freqs[note],amps[note]);
    // The envelope gets triggered with the oscillator as input and the times and 
    // levels we defined earlier
    env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    
    trigger = millis() + rhythms[note];
    note++;//move along to next pixel/note 
  }
  updatePixels();
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
        pixels[loc] = color(int(gray));
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
