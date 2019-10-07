import processing.sound.*;
import beads.*;
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
/*
Note to clour mappings will be as follows:
A - Red 
Bb - Gold
B - Pink 
C - White 
Db - Purple 
D - Yellow
Eb - Beige 
E - Blue
F - Orange 
F# - Black 
G - Green
G# - Crimson
*/
PImage pic;
AudioContext ac;

void setup(){
  //TODO
  //size(460,461);
  //oof = loadImage("th.jpg");
  ac = new AudioContext();
  size(1587, 794);
  noLoop();
  pic = loadImage("test image 4.png");
  //pic = createImage(width, height, ARGB);
  len = pic.pixels.length;
  
  Gain masterGain = new Gain(ac,1,1);
  Clock clock = new Clock(ac, 700); //triggers events this time
  clock.addMessageListener(
    new Bead() {
      int pitch, prePitchR, prePitchG, prePitchB, prep;
      public void messageReceived(Bead message) {
         Clock c = (Clock) message;
         if(c.isBeat()) {
          //choose some nice frequencies 
          if(random(1) < 0.5) return;
          prePitchR = (int) red(dominantArr[0]);
          prePitchG = (int) green(dominantArr[0]);
          prePitchB = (int) blue(dominantArr[0]);
          prep = (prePitchR+prePitchG+prePitchB)/765;
          pitch = Pitch.forceToScale((int)(prep*12), Pitch.dorian);
          float freq = Pitch.mtof(pitch + (int)random(5) * 12 + 32);
          WavePlayer wp = new WavePlayer(ac, freq, Buffer.SINE);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0));
          g.addInput(wp);
          ac.out.addInput(g);
          ((Envelope)g.getGainEnvelope()).addSegment(0.1, random(200));
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(7000), new KillTrigger(g));
         }
         if(c.getCount() % 8 == 0) {
           //choose some nice frequencies
          int pitchAlt = pitch;
          if(random(1) < 0.2) pitchAlt = Pitch.forceToScale((int)random(12), Pitch.dorian) + (int)random(2) * 12;
          float freq = Pitch.mtof(pitchAlt + 32);
          WavePlayer wp = new WavePlayer(ac, freq, Buffer.SQUARE);
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
  background(pic);//show the image input while music plays 
  map = countColorsIntoMap(pic.pixels);
  sortedMap = sortMapByValues(map);
 
  dominantMap.clear();
  java.util.Arrays.fill(dominantArr, 0);
 
  println("\nUnique colors found:", map.size(), "\tfrom:", len, ENTER);
 
  int idx = 0;
  for (final Entry<Integer, Integer> colors : sortedMap.entrySet()) {
    dominantMap.put(dominantArr[idx] = colors.getKey(), colors.getValue());
    if (++idx == QTY)  break;
  }
 
  idx = 0;
  for (final Entry<Integer, Integer> colors : dominantMap.entrySet())
    println(idx++, "->", hex(colors.getKey(), 6), "\tcount:", colors.getValue());
 
  println();
  println(dominantMap, ENTER);
  println(dominantArr);
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
