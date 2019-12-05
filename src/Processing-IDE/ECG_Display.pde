
import processing.serial.*;
Serial myPort; 
int xPos = 1;        
float height_old = 0;
float height_new = 0;
float inByte = 0;
int BPM = 0;
int beat_old = 0;
float[] beats = new float[500];  
int beatIndex;
float threshold = 620.0;  
boolean belowThreshold = true;
PFont font;

void setup () {  
  size(1260, 620); 
  println(Serial.list());   
  myPort = new Serial(this, Serial.list()[4], 9600); 
  myPort.bufferUntil('\n'); 
  background(0xff);  
}

void draw () {
  
  
      int beat_new = millis();
      if (millis() % 128 == 0){
        fill(0xFF);
        rect(0, 0, 200, 20);
        fill(0x00);
        text("BPM: " + inByte, 15, 10);
       }
      calculateBPM();

}
void serialEvent (Serial myPort) {
  
  String inString = myPort.readStringUntil('\n'); 

  if (inString != null) {  
  
    inString = trim(inString);  // trim off any whitespace: 
    
    if (inString.equals("!")) { // If leads off detection is true notify with blue line
      stroke(0, 0, 0xff); //Set stroke to blue ( R, G, B)
      inByte = 512;  // middle of the ADC range (Flat Line)
    }    
    else { // If the data is good let it through
      stroke(0xff, 0, 0); //Set stroke to red ( R, G, B)
      inByte = float(inString);
    }    
     
    inByte = map(inByte, 0, 1023, 0, height); //Map and draw the line for new data point
    height_new = height - inByte; 
    line(xPos - 1, height_old, xPos, height_new);
    height_old = height_new;    
    //calculateBPM();
    
    if (xPos >= width) { // at the edge of the screen, go back to the beginning:
      xPos = 0;
      background(0xff);
      
    } 
    else {        
      xPos++;// increment the horizontal position:
    } 
   
      
  }
}
void calculateBPM () 
{  
  int beat_new = millis();    // get the current millisecond
  int diff = beat_new - beat_old;    // find the time between the last two beats
  float currentBPM = 60000 / diff;    // convert to beats per minute
  beats[beatIndex] = currentBPM;  // store to array to convert the average
  float total = 0.0;
  for (int i = 0; i < 500; i++){
    total += beats[i];
  }
  BPM = int(total / 500);
  beat_old = beat_new;
  beatIndex = (beatIndex + 1) % 500; 
  // cycle through the array instead of using FIFO queue
  }
