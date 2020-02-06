import javax.swing.*;
import controlP5.*;//Andreas Schlegel's Controller library

public ControlP5 controlP5;
public ControlWindow controlWindow;
int myColorBackground = color(0,0,0);

public int colorValue = 0;//default tool values
public int pixelValue = 1;
public int noTiles = 4;
public Numberbox myNumberbox;

// create a file chooser 
public JFileChooser fc;
public File file; //Must be jpg, gif, tga or png image file 

public PImage img;//image holders
public PImage origImg;


void setup() {

 try {
   fc = new JFileChooser();
int returnVal = fc.showOpenDialog(null);    
if (returnVal == JFileChooser.APPROVE_OPTION) { //1
  file = fc.getSelectedFile(); 
  // see if it's a Processing supported image 
  String fileName = file.getName().toLowerCase();
  if (fileName.endsWith("jpg") || fileName.endsWith("gif") || fileName.endsWith("tga")
       || fileName.endsWith("png"))
  {
    // load the image using the given file path
    img = loadImage(file.getPath()); 
    if (img != null) {
     origImg = createImage(img.width, img.height, RGB); //make copy of original image
     //arraycopy(img.pixels, origImg.pixels);
     for(int i = 0; i < origImg.pixels.length; i++){
       origImg.pixels[i] = img.pixels[i];
     }//for
     // size the window and show the image
     size(2160,1080); 
     image(img,0,0); 
     frameRate(25);
    controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
  controlWindow = controlP5.addControlWindow("controlP5window",0,0,2160,1080);
  controlWindow.setBackground(color(myColorBackground));
  ControllerGroup infoTextarea = controlP5.addTextarea("label",
  "To use any of the three program widgets below, you must \n"+
  "place the cursor over the widget and keep the left button \n"+
  "pressed down. Both sliders must be returned to their left- \n"+
  "most default values before using the numberBox tiling tool. \n"+
  "Placing the cursor over or near the number in the numberBox \n"+
  "will cause the row/col value of number of tiles to change.  \n"+
  "NOTE, repaint times can be several seconds.",50,0,300,100);
  infoTextarea.setColorValue(#FFFFFF);
  infoTextarea.moveTo(controlWindow);
  Slider mySlider1 = controlP5.addSlider("colorSlider",0,255,0,50,100,200,20);
  Slider mySlider2 = controlP5.addSlider("pixellateSlider",1,20,1,50,150,200,20);
  //mySlider1.addControlWindow(controlWindow);
  //mySlider2.setWindow(controlWindow);
  myNumberbox = controlP5.addNumberbox("numberboxTilingTool",4,50,200,100,14);
  //myNumberbox.setWindow(controlWindow);
   } 
  } 
  else { 
    println("Unsupported file selected by user."); 
    System.exit(0);
   } 
}  

} catch (Exception e) { 
  e.printStackTrace();  
}
}


void draw() {
 
  //background(img);
  colorChange(pixelValue);
  controlP5.draw();
  noLoop(); //stops continuous screen repaints
}

void colorChange(int detail) {
  
    arraycopy(origImg.pixels, img.pixels);
    noStroke();
    detail = pixelValue;
    for (int i=0; i<width; i+=detail) {
      for (int j=0; j<height; j+=detail) {
        color c = img.get(i,j);
        fill(c+colorValue);
        img.set(i, j, c+colorValue);
        rect(i,j,detail,detail);
      }
  } return;
}  

void setTiles() {
    
    int w = width/noTiles;
    int h = height/noTiles;
    for (int i=0; i<height; i+=h) {
      for (int j=0; j<width; j+=w) {
      image(img,j,i,w,h);
      }
    } return;
}  

void colorSlider(int colValue) {
  colorValue = colValue;//sets sliderValue = value of "slider"
  redraw();
}

void pixellateSlider(int pixValue) {
  pixelValue = pixValue;//sets pixelValue = value of "pixellate"
  redraw();
}

void numberboxTilingTool(int theColor) {
  noTiles = theColor; 
  setTiles();
  redraw();
}
