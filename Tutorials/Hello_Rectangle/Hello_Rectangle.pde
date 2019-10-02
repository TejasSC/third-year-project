float x, y;
double theta, step;

void setup(){
  size(1000, 800);
  x = 500;
  y = 700;
  theta = 0;
  step = Math.PI/40;
}

//called every time stuff is drawn, sometimes called the draw loop
//default animation rate is 60 fps
void draw() {
  circle(0, -200);
  circle(1, 0);
  circle(2, 200);
}
void circle(int col, int offset){
  //noStroke: removes outline
  noStroke();
  //using fill(r, g, b)
  if(col == 0){fill(128, random(255), 255);}
  else if(col == 1){fill(random(255), 128, 255);}
  else if(col == 2){fill(128, 255, random(255));}
  
  float r = 20;
  //for(float theta=0;  theta < 2*Math.PI;  theta+=step)
  if(theta>=2*Math.PI){ 
    theta = 0; y-=10;
  } else {
   x = (float)(x + r*Math.cos(theta));
   y = (float)(y - r*Math.sin(theta));
   ellipse(x+offset,y,90,90);
   theta+=step;
 }
 if(y < 100){y = width/2;}
}
