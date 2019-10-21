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
float[] freqs;
int pitch, trigger;
int[] playSound = {0,0,0,0,0};
int[] hist, topVals;
SoundFile[] chords, usedChords;
SoundFile drums;
//musical intervals which we can transpose up by 
//minor 2nd, major 2nd, minor 3rd, major 3rd, perfect 4th, tritone, perfect 5th
float[] uprates = {16/15, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2};
void setup(){
  //TODO
  //size(460,461);
  //oof = loadImage("th.jpg");
  drums = new SoundFile(this, "drum pattern.wav");
  drums.loop(1,0.0,0.3,0);
  chords = new SoundFile[12];
  usedChords = new SoundFile[5];
  for(int i = 0; i < chords.length; i++){
    chords[i] = new SoundFile(this, "chord " + i + ".wav");
  }
  ac = new AudioContext();
  size(1734, 867);
  noLoop();
  img = loadImage("test image 0.png");
  hist = new int[256];
  topVals = new int[5];
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
  //decide which five of 12 chords we will use in the playback 
  for(int i = 0; i < topVals.length; i++){
    topVals[i] = hist[(hist.length - 1)-i];
    //System.out.println(red(topVals[i]));
    //System.out.println(green(topVals[i]));
    //System.out.println(blue(topVals[i]));
    //System.out.println();
    int prePitchR = (int) red(topVals[i]);
    int prePitchG = (int) green(topVals[i]);
    int prePitchB = (int) blue(topVals[i]);
    float ratio = (prePitchR+prePitchG+prePitchB)/765;
    usedChords[i] = chords[(int)(ratio*(chords.length - 1))];
  }
  /*
  Gain masterGain = new Gain(ac,1,1);
  Clock clock = new Clock(ac, 700); //triggers events this time
  clock.addMessageListener(
    new Bead() {
      public void messageReceived(Bead message) {
         Clock c = (Clock) message;
         if(c.isBeat()) {
           int note1 = (int)random(12);
           int note2 = (int)random(12);
           float freq1 = freqs[note1];
           float freq2 = freqs[note2];
           WavePlayer wp1 = new WavePlayer(ac, freq1, Buffer.SINE);
           WavePlayer wp2 = new WavePlayer(ac, freq2, Buffer.SINE);
           Gain g = new Gain(ac, 1, new Envelope(ac, 0));
           g.addInput(wp1);
           g.addInput(wp2);
           ac.out.addInput(g);
           ((Envelope)g.getGainEnvelope()).addSegment(0.1, random(200));
           ((Envelope)g.getGainEnvelope()).addSegment(0, random(7000), new KillTrigger(g));          
         }
         if(c.getCount() % 8 == 0) {
           //choose some nice frequencies
           int note1 = (int)random(12);
           int note2 = (int)random(12);
           float freq1 = freqs[note1];
           float freq2 = freqs[note2];
          int pitchAlt = Pitch.forceToScale((int)random(12), Pitch.dorian) + (int)random(2) * 12;
          float freq = Pitch.mtof(pitchAlt + 32);
          WavePlayer wp = new WavePlayer(ac, freq, Buffer.SINE);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0));
          g.addInput(wp);
          Panner p = new Panner(ac, random(1));
          p.addInput(g);
          ac.out.addInput(p);
          ((Envelope)g.getGainEnvelope()).addSegment(random(0.1), random(50));
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(400), new KillTrigger(p));
         }
       if(c.getCount() % 6 == 0) {
          //Noise n = new Noise(ac);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0.05));
          //g.addInput(n);
          Panner p = new Panner(ac, random(0.5, 1));
          p.addInput(g);
          ac.out.addInput(p);
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(100), new KillTrigger(p));
         }
      }
    }
  );
  ac.out.addDependent(clock);
  ac.start();
  */
}

void draw(){
  if (millis() > trigger) {
    int chord = (int)random(0,4);
     
    // Renew the indexes of playSound so that at the next event 
    // the order is different and randomized.
    playSound[chord] = 1;
    // By iterating through the playSound array we check for 
    // 1 or 0, 1 plays a sound and draws a rect
    for (int i = 0; i < usedChords.length; i++) {      
      // Check which indexes are 1 and 0.
      if (playSound[i] == 1) {
        playSound[i] = 0;
        // Play the soundfile from the array with the respective 
        // rate and loop set to false
        usedChords[i].amp(0.9);
        usedChords[i].play(1, 1.0);
      }
    }

    // Create a new triggertime in the future, with a random offset 
    // between 200 and 1000 milliseconds
    trigger = millis() + 1900;
    
  }
}
