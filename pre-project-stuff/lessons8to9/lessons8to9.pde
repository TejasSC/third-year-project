import beads.*;
import java.util.Arrays; 

AudioContext ac;
PowerSpectrum ps;//lesson 9, displays visual representation of sample  

void setup() {
  size(700,700);
  ac = new AudioContext();
  selectInput("Select an audio file:", "fileSelected");
}

/*
 * This code is used by the selectInput() method to get the filepath.
 */
void fileSelected(File selection) {
  /*
   * In lesson 4 we played back samples. This example
   * is almost the same but uses GranularSamplePlayer
   * instead of SamplePlayers
   */
  String audioFileName = selection.getAbsolutePath();//like in lesson 4
  Sample sample = SampleManager.sample(audioFileName);
  //Lesson 8:GranularSamplePlayer player = new GranularSamplePlayer(ac, sample);
  SamplePlayer player = new SamplePlayer(ac, sample);
  /*
   * Have some fun with the controls.
  
   //loop the sample at its end points
   player.setLoopType(SamplePlayer.LoopType.LOOP_ALTERNATING);
   player.getLoopStartEnvelope().setValue(0);
   player.getLoopEndEnvelope().setValue((float)sample.getLength());
   //control the rate of grain firing
   Envelope grainIntervalEnvelope = new Envelope(ac, 120);
   grainIntervalEnvelope.addSegment(20, 10000); //end value, 10sec duration 
   player.setGrainIntervalEnvelope(grainIntervalEnvelope);
   //control the playback rate
   Envelope rateEnvelope = new Envelope(ac, 1);
   rateEnvelope.addSegment(1, 5000);
   rateEnvelope.addSegment(0, 5000);
   rateEnvelope.addSegment(0, 2000);
   rateEnvelope.addSegment(-0.1, 2000);
   rateEnvelope.addSegment(-0.6,5000);
   player.setRateEnvelope(rateEnvelope);
   //a bit of noise can be nice
   player.getRandomnessEnvelope().setValue(0.02);
  */
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  //signal analysis done by building an analysis chain 
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);
  FFT fft = new FFT();
  ps = new PowerSpectrum();
  sfs.addListener(fft);
  fft.addListener(ps);//power spectrum added as listener 
  ac.out.addDependent(sfs);
  ac.start();
}


/*
 * Here's the code to draw a scatterplot waveform.
 * The code draws the current buffer of audio across the
 * width of the window. To find out what a buffer of audio
 * is, read on.
 * 
 * Start with some spunky colors.
 */
color front = color(255, 102, 204);
color bacc = color(0,0,0);

/*
 * Just do the work straight into Processing's draw() method.
 */
void draw() {
  /*
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
  */
  background(bacc);
  stroke(front);
  int featureIndex, vOffset, res1;
  if(ps == null) return;
  float[] feats = ps.getFeatures();
  if(feats != null) {
    //scan across the pixels
    for(int i = 0; i < width; i++){
      featureIndex = i*feats.length / width;
      res1 = (int)(feats[featureIndex] * height);
      vOffset = height - 1 - Math.min(res1, height - 1);
      line(i,height,i,vOffset);
    }
  }
}
