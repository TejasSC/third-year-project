class Bubble {
  float x, y, diameter;
  PImage img;
  
  
  Bubble(float xTemp, float yTemp, float tempD, PImage pic){
    x = xTemp; y = yTemp; diameter = tempD; img = pic;
  }
  
  void goUp(){
    y--;
    x += random(-2,2);
  }
  void display(int i){
    stroke(0);
    fill(127);
    ellipse(x,y,diameter, diameter);
    imageMode(CENTER);
    image(img,x,y,diameter, diameter);
  }
  void top(){
    if(y < diameter/2){
      y = diameter/2;
    }
  }
}
