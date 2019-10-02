float xSpeed = 5.6, x = 600, y = 300;
void setup(){
  size(800,600);
}

void draw(){
  background(0);
  ball(-200);
  ball(0);
  ball(200);
}

void ball(int offset) {
  x+=xSpeed;
  if(x > width || x < 0) {
    xSpeed = xSpeed * -1;
  }
  ellipse(x,y+offset,50,50);
}
