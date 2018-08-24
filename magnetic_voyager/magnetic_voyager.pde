import processing.serial.*;
Serial port;
PFont sourceCode;

// Mag data.
int byteCount = 0;
int axisData = -10000;
int barHeight;
boolean firstContact = false;

// Graph.
int numX = 15; int numY = 10;
int xPos; int yPos;
int barWidth;
int barHeightMax;
int margin = 5;

int frameCounter = 0;
int drawCounter = 0;
int[] barHeightArray = new int[numX*numY];
int[] barHeightAnimate = new int[numX*numY];

// Binary.
String lastVal = " ";
int textStart = 1;
String binaryVal;
float ts = 9.025;
int counter = 1;
float ySteps = ts * counter;

// Page layout for full screen mode. HS = Height Start. WE = Width End.
int graphHS; int graphHE; int graphWS; int graphWE; int graphWidth;
int binaryHS; int binaryHE; int binaryWS; int binaryWE; int binaryHeight;

void setup()  {
  fullScreen();
  frameRate(60);
  background(0);
  rectMode(CORNERS);
  noStroke();
  noCursor();
  
  sourceCode = createFont("SourceCodePro-Regular", ts);
  textFont(sourceCode);
  textSize(ts);
  
  port = new Serial(this, Serial.list()[3], 9600);
  
  // Create data for the initial graph.
  for (int i = 0; i < numX*numY; i++)  {
    barHeightArray[i] = 1;
    barHeightAnimate[i] = 1;
  }
  initLayout();
}

void draw()  {
  distGraph();
  distBinary();
}

void serialEvent(Serial port)  {
  int inByte = port.read();
  if (firstContact == false)  {
    if (inByte != 'A')  {
      port.clear();
    } else if (inByte == 'A')  {
      port.clear();
      firstContact = true;
      port.write('A');
    }
  } else   {
    axisData = inByte;
    byteCount++;
    if (byteCount > 0)  { // Update the number if sending multiple pieces of data
                          // through the serial port.
      barHeight = round(map(axisData, 0, 255, 1, (graphHE/numY)));
      port.write('A');
    }
  }
}

void initLayout()  {
  graphHS = layoutCalc(1, height);
  graphHE = layoutCalc(6, height);
  graphWS = layoutCalc(3, width);
  graphWE = layoutCalc(7, width);
  graphWidth = graphWE - graphWS;
  
  barWidth = (graphWidth-(margin*(numX-1))) / numX;
  barHeightMax = layoutCalc(7, graphHE/numY);
  
  binaryHS = layoutCalc(7, height);
  binaryHE = layoutCalc(8.5, height);
  binaryWS = layoutCalc(3, width);
  binaryWE = layoutCalc(7, width);
  binaryHeight = binaryHE - binaryHS;
}

int layoutCalc(float val, int total)  {
  int returnVal = round(map(val, 0, 10, 0, total));
  return returnVal;
}

void distGraph()  {
  fill(0);
  rect(0, 0, width, graphHE);
  fill(255);
  
  if (axisData != -10000)  {
    if (drawCounter == 0 && frameCounter < numX*numY)  {
      barHeightArray[frameCounter] = barHeight;
      frameCounter++;
    }
  }
  drawCounter++; // Regulates speed.
  if (drawCounter == 5)  {
    drawCounter = 0;
  }
  
  // Draws the graph and calculates animation.
  int barNum = 0;
  for (int ySteps = 0; ySteps < numY; ySteps++)  {
    xPos = graphWS;
    for (int xSteps = 0; xSteps < numX; xSteps++)  {
      yPos = round(map(ySteps + 1, 0, numY, graphHS, graphHE));
      if (barHeightAnimate[barNum] < barHeightArray[barNum])  {
        barHeightAnimate[barNum] += 1; // Animates the bars.
        barHeightArray[barNum] = constrain(barHeightArray[barNum], 0, barHeightMax);    
        rect(xPos, yPos, xPos+barWidth, yPos+(barHeightAnimate[barNum]*-1));
      } else  {
        rect(xPos, yPos, xPos+barWidth, yPos+(barHeightArray[barNum]*-1));
      }
      xPos += (barWidth + margin);
      barNum++;
    }
  }
    
  // If display is full, remove the data with an animation. Reset the counter.
  if (frameCounter == numX*numY)  {
    int shrinkCount = 0;
    for (int i = 0; i < barHeightArray.length; i++)  {
      if (barHeightArray[i] > 1)  {
        barHeightArray[i] -= 1;
      } else if (barHeightArray[i] == 1)  {
        shrinkCount++;
        if (shrinkCount == numX * numY)  { // If all bars have reset, restart animation.
          for (int r = 0; r < barHeightArray.length; r++)  {
            barHeightAnimate[r] = 1;
          }
          frameCounter = 0;
        }
      }
    }
  }
}

void distBinary()  {
  if (counter > binaryHeight/ts)  {
    fill(0);
    rect(0, binaryHS, width, binaryHS + binaryHE);
    fill(255);
    counter = 1;
    lastVal = " ";
  }
  
  ySteps = ts * counter;
  if (axisData != -10000)  {
    binaryVal = binary(int(axisData), 8);
    if (binaryWS + textWidth(lastVal + binaryVal) < binaryWE)  {
      text((binaryVal) + "  ", binaryWS + textWidth(lastVal), binaryHS + ySteps);
    }
    if (binaryWS + textWidth(lastVal + binaryVal) > binaryWE)  { // Starts new line.
      lastVal = " ";
      counter++;
      ySteps = ts * counter;
      text((binaryVal) + "  ", binaryWS + textWidth(lastVal), binaryHS + ySteps);
    }
    lastVal += binaryVal + "  ";
  }
}
