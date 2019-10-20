import processing.sound.*;
import beads.*;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import static java.util.Map.Entry;
import java.util.LinkedHashMap;

static final int QTY = 12, VARIATION = 50;
final color[] dominantArr = new color[QTY];
final Map<Integer, Integer> dominantMap =
  new LinkedHashMap<Integer, Integer>(QTY, 1.0);
Map<Integer, Integer> map, sortedMap; int len;
PImage img;
AudioContext ac;
float[] freqs;
int pitch;
int[] hist, topVals;
SoundFile[] chords;
void setup(){
  //TODO
  //size(460,461);
  //oof = loadImage("th.jpg");
  chords = new SoundFile[7];
  for(int i = 0; i < 7; i++){
    chords[i] = new SoundFile(this, "chord " + i + ".wav");
  }
  ac = new AudioContext();
  size(1734, 867);
  noLoop();
  img = loadImage("test image 0.png");
  hist = new int[256];
  topVals = new int[12];
  freqs = new float[12];
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
  for(int i = 0; i < topVals.length; i++){
    topVals[i] = hist[(hist.length - 1)-i];
    System.out.println(topVals[i]);
  }
  //pic = createImage(width, height, ARGB);
  
  //populate freqs  
  //for(int i = 0; i < topVals.length; i++){
  //  int prePitchR = (int) red(topVals[i]);
  //  int prePitchG = (int) green(topVals[i]);
  //  int prePitchB = (int) blue(topVals[i]);
  //  float ratio = (prePitchR+prePitchG+prePitchB)/765;
  //  pitch = Pitch.forceToScale((int)(ratio*12), Pitch.dorian);
  //  freqs[i] = Pitch.mtof(pitch + (int)random(5) * 12 + 32);
  //}
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
}

void draw(){
  //loadPixels();
  //pic.loadPixels();
  //for(int x = 0; x < width; x++){
  //  for(int y = 0; y < height; y++){
  //    int loc = x + y*width;
  //    //take column of pixels
  //    //find most common colours in that 
  //    //map colours to that 
  //  }
  //}
  //updatePixels();

}
void mousePressed() {
  redraw = true;
}
 
static final Map<Integer, Integer> countColorsIntoMap(final color... colors) {
  final Map<Integer, Integer> map = new HashMap<Integer, Integer>();
 
  for (color c : colors) {
    final Integer count = map.get(c &= ~#000000); // c |= #000000
    map.put(c, count == null? 1 : count + 1);
  }
 
  return map;
}
 
static final <K extends Comparable<K>, V extends Comparable<V>>
  Map<K, V> sortMapByValues(final Map<K, V> map)
{
  final int len = map.size(), capacity = ceil(len/.75) + 1;
  final List<Entry<K, V>> entries = new ArrayList<Entry<K, V>>(map.entrySet());
 
  Collections.sort(entries, new Comparator<Entry<K, V>>() {
    @ Override public int compare(final Entry<K, V> e1, final Entry<K, V> e2) {
      final int sign = e2.getValue().compareTo(e1.getValue());
      return sign != 0? sign : e1.getKey().compareTo(e2.getKey());
    }
  });
 
  final Map<K, V> sortedMap = new LinkedHashMap<K, V>(capacity);
  for (final Entry<K, V> entry : entries)
    sortedMap.put(entry.getKey(), entry.getValue());
 
  return sortedMap;
}
