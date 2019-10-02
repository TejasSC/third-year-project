import beads.*; 
import java.util.Arrays;

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

AudioContext ac;

void setup() {
  size(300,300);
  ac = new AudioContext();
  selectInput("choose an audio file:", "fileSelected");//Lesson 4
}
//selectInput method uses this to get specified filepath 
void fileSelected(File selection){
  /*
   //envelopes: changes behaviour of another UGen object
   //must do this to get precise obctrol of certain params at an audio rate
   //Envelope freqEnv = new Envelope(ac, 128);//Lesson 2 
   //WavePlayer freqModulator = new WavePlayer(ac, 5, Buffer.SINE); 
   //WavePlayer wp = new WavePlayer(ac, freqEnv, Buffer.SINE);//Lesson 2
   //Wave Player: takes above envelope and sinebuffer as arguments.
   //change to 1000 in 1000ms, from 500 (look at before)
   //freqEnv.addSegment(440,500);//Lesson 2 
   
   //Lesson 3 stuff 
   Function function = new Function(freqModulator){
     //maps freqModulator/sine wave to a sensible range 
     public float calculate() {
       return x[0]*10.0 + 512.0;
       //x[0]*amplitude + base frequency, wavePlayer.arg2 times/sec 
     }
   };
   WavePlayer wp = new WavePlayer(ac, function, Buffer.SINE);//Lesson 3 
   * gain control object 
   arg1 = audioContext, arg2 = number of channels, arg3= intial gain level
   */
   String audioFN = selection.getAbsolutePath();
   SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFN));
   
   Envelope speedControl = new Envelope(ac, 1);
   player.setRate(speedControl);
   speedControl.addSegment(1,1000);//wait a second 
   speedControl.addSegment(-1.0,3000);//rewind and play from beginning 
   
   Gain g = new Gain(ac, 2, 0.2);
   g.addInput(player);//add sampleplayer as gain input, lesson 4 
   ac.out.addInput(g);
   ac.start();//start running stuff 
}

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
