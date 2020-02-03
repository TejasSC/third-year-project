import beads.*;
import java.util.Arrays;

AudioContext ac;
void setup(){
  frameRate(200);
  size(300,300);
  ac = new AudioContext();
  Gain masterGain = new Gain(ac,1,1);
  
  Clock clock = new Clock(ac, 700); //triggers events this time
  
  /*
  //Connecting two wavePlayers (one with frequency envelope) 
  Envelope freqEnv = new Envelope(ac,160);//Lesson 6
  WavePlayer wp = new WavePlayer(ac, freqEnv, Buffer.SINE);
  Gain g1 = new Gain(ac, 1, -0.3);
  g1.addInput(wp);
  WavePlayer wp2 = new WavePlayer(ac, 135, Buffer.SQUARE);
  Gain g2 = new Gain(ac, 1, -0.1);
  g2.addInput(wp2);
  masterGain.addInput(g1);
  masterGain.addInput(g2);
  
  //Gain envelope will now fade to zero over 5000 ms
  //then fires event to listener 
  //In this case, the event is stopping second sound by killing gain 2 
  //Killing any UGen removes it from signal chain, and also removes all things
  //upstream from it 
  //freqEnv.addSegment(270,2000, new KillTrigger(g2));
  
  //Lesson 5 
  //Envelope intervalEnvelope = new Envelope(ac, 1000);
  /*intervalEnvelope.addSegment(600, 10000);
  intervalEnvelope.addSegment(1000, 10000);
  intervalEnvelope.addSegment(400, 10000);
  intervalEnvelope.addSegment(1000, 10000);
  
  //Lesson 5 
  //clock initialised within envelope 
  //Clock clock = new Clock(ac, intervalEnvelope);
  //clock.setClick(true);
  //clock will now tick: a very helpful debugging tool 
  //clock has no outputs, therefore cannot add it to audio context 
  //to get it to actually run, must use addDependent instead 
  */
  clock.addMessageListener(
    new Bead() {
      int pitch;
      public void messageReceived(Bead message) {
         Clock c = (Clock) message;
         if(c.isBeat()) {
          //choose some nice frequencies 
          if(random(1) < 0.5) return;
          pitch = Pitch.forceToScale((int)random(12), Pitch.major);
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
          Noise n = new Noise(ac);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0.05));
          g.addInput(n);
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
}//clock, lesson 5 

/*
 * Here's the code to draw a scatterplot waveform.
 * The code draws the current buffer of audio across the
 * width of the window. To find out what a buffer of audio
 * is, read on.
 * 
 * Start with some spunky colors.
 */
color fore = color(255, 102, 204);
color back = color(0,0,0);

/*
 * Just do the work straight into Processing's draw() method.
 */
void draw() {
  loadPixels();
  //set the background
  Arrays.fill(pixels, back);
  //scan across the pixels
  for(int i = 0; i < width; i++) {
    //for each pixel work out where in the current audio buffer we are
    int buffIndex = i * ac.getBufferSize() / width;
    //then work out the pixel height of the audio data at that point
    int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * height / 2);
    //draw into Processing's convenient 1-D array of pixels
    vOffset = min(vOffset, height);
    pixels[vOffset * height + i] = fore;
  }
  updatePixels();
}
