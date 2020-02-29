float x = 50;
float y = 50;
float directionX = 1;
float directionY = 1;
boolean playOver = false;
boolean pauseOver = false;


void setup() {
  size(400, 300);
  noStroke();  
}

void draw() { 
  background(0); 
 
  x += 3 * directionX;
  y += 3 * directionY;  
  
  if (x > width-15 || x < 15) {
    directionX = -directionX;    
  }
  if (y > height-15 || y < 15) {
    directionY = -directionY;
  }  

  fill(255, 150); 
  ellipse(x, y, 15, 15);

  update(mouseX, mouseY);    
  
  fill(0, 255, 0);
  ellipse(100, 150, 75, 75);
  fill(255, 0, 0);
  ellipse(300, 150, 75, 75);  
}


void update (float x, float y) {   
  if( overPlay(100, 150, 75) ) {
    playOver = true;
    pauseOver = false;
  } else if( overPause(300, 150, 75) ) {
    pauseOver = true;
    playOver = false;
  } else {
    playOver = pauseOver = false;
  }  
}

void mousePressed() {
  if(pauseOver) {
    noLoop();
  }
  if(playOver) {    
    loop();
  } 
}

boolean overPlay(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2) {
    return true;
  } else {
    return false;
  }  
}

boolean overPause(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2) {
    return true;
  } else {
    return false;
  }  
}
