import controlP5.*;
 
ControlP5 cp5;
 
Textfield input; 
Textarea output;
 
String textValue = "";
StringList script;
int index = 0; 
 
void setup() { 
  size(1000, 700, P3D); 
  frameRate(15);
 
  PFont font = createFont("arial", 20);
 
  cp5 = new ControlP5(this);
 
  script = new StringList();
  input = cp5.addTextfield("input") 
  .setColor(color(0)) 
  .setColorBackground(color(255, 255, 255, 29)) 
  .setColorCursor(color(0)) 
  .setPosition(10, 10) 
  .setSize(980, 40) 
  .setFont(font) 
  .setFocus(true) ;
 
  output = cp5.addTextarea("output") 
  .setColor(color(0)) 
  .setColorBackground(color(255, 255, 255, 29)) //.setColorCursor(color(0)) 
  .setPosition(10,70) 
  .setSize(980,600) 
  .setFont(font) ;
}
 
void draw() { 
  background(255);
}
 
void controlEvent(ControlEvent theEvent) { 
  index = index + 1; 
  textValue = input.getText(); 
  //println(textValue); 
  script.append(textValue+"\n"); 
  //String item = script.get(index-1); 
  //item +=item + "\n"; 
  //output.setText(item + "\n"); 
  output.clear();
 
  String fullStr="";
  for(String s:script)
    fullStr+=s;
 
  output.setText(fullStr);
}
