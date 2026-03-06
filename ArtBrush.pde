// Variables used to detect the vertical limits of each color square in the palette
int rectTop, rectBottom; 

// Position of the color palette
int xPalette = 1100; 
int yPalette = 50;

// Position and size of the reset button
int xButton = 1100;
int yButton = 470;
int wButton = 50;
int hButton = 35;

// Brush settings
int brushSize = 10;
color brushColor = 255;

// Array that stores the palette colours
color [] palette;

// Generate a new variable for the drawing layer
PGraphics canvas;

// Generate snapshots
ArrayList<PImage> undoStack = new ArrayList<PImage>();
ArrayList<PImage> redoStack = new ArrayList<PImage>();

int maxUndo = 20; // memory limit


void setup() {
  size(1200, 720); // Create the window
  canvas = createGraphics (1200, 720); // Initialise the canvas
  resetCanvas(); // Initialise the background
  palette = new color [] { color(242, 73, 113), color(208, 255, 143), color(143, 156, 255), color(247, 204, 137), color(255, 122, 224), color (255, 255, 255), color(0, 0, 0) }; // Define the palette colours
  textSize(15); // Set the text size for the reset button label
  noCursor();
}

void draw() { 
  // Draw the canvas
  image(canvas, 0, 0);
  
   // Draw the colour palette
  for (int i = 0; i < palette.length; i++) {
    fill(palette[i]);  // Set the fill color for each palette square
    stroke(255); // White border
    strokeWeight(1);
    int rectY = yPalette + i*60; // Calculate the vertical position of each square
    rect(xPalette, rectY, 50, 50); // Draw the palette square
  }
  
  // Detect if the mouse is hovering over the reset button
  if (mouseX >= xButton && mouseX <= xButton + wButton && mouseY >= yButton && mouseY <= yButton + hButton) fill(130, 130, 130); // Lighter colour when hovering
  else fill(77, 77, 77); // Default button colour
  
  // Draw the reset button
  rect(xButton, yButton, wButton, hButton);
  
  // Draw the button label
  fill(255);
  text("Reset", xButton + 8, yButton + 23);
  
  // Draw the instructions for the user
  fill(189, 189, 189);
  rect(xButton - 60, yButton +45, 110, 70);
  fill(0);
  text("Press S to save", xButton - 50, yButton +65);
  text("Press Z to undo", xButton - 50, yButton +85);
  text("Press Y to redo", xButton - 50, yButton +105);
  
  // Draw the cursor
  noStroke();
  fill(brushColor);
  ellipse(mouseX, mouseY, brushSize, brushSize);
}

void mouseDragged() {
  canvas.beginDraw();
  canvas.stroke(brushColor); // Use the selected brush colour
  canvas.strokeWeight(brushSize); // Use the current brush size
  canvas.line(pmouseX, pmouseY, mouseX, mouseY); // Draw a line following the mouse movement (from the previous position of the mouse -pmouseX and pmouseY- to the current position -mouseX and mouseY-)
  canvas.endDraw();
}

void mousePressed() {
  
   // Undo functionality
   undoStack.add(canvas.get());
   redoStack.clear(); // If the user draws again, the redo is cleared
   
   if (undoStack.size() > maxUndo) {
     undoStack.remove(0); // Removes the oldest snapshot
    } 
    
  // Check if the user clicked on any color in the palette
  for (int i = 0; i < palette.length; i++) {
    // Calculate the vertical limits of the palette square
    rectTop = yPalette + i*60;
    rectBottom = rectTop + 50;
      // If the mouse click is inside the palette square
      if (mouseX >= xPalette && mouseX <= (xPalette + 50) && mouseY >= rectTop && mouseY <= rectBottom) {
        brushColor = palette[i]; // Change the brush colour to the selected palette colour
      }
  }
  
  // Check if the reset button was clicked
  if (mouseX >= xButton && mouseX <= xButton + wButton && mouseY >= yButton && mouseY <= yButton + hButton) {
    resetCanvas(); // Clear the canvas
  }
}

void keyPressed() {
  // Increase brush size
  if (key == '+') {
    brushSize = brushSize + 5;
  }
  
  // Decrease brush size
  if (key == '-') {
    brushSize = brushSize - 5;
    // Prevent the brush from becoming too small
    if (brushSize <= 1) {
      brushSize = 1;
    }
  }
  
  // Save the drawing
  if (key == 's' || key == 'S'){
    canvas.save("myDrawing.png");
  }
  
  // Undo
  if ((key == 'z' || key == 'Z') && undoStack.size() > 0){
    redoStack.add(canvas.get()); // Save the current canvas state to the redo stack in case the user wants to redo
    
    PImage previous = undoStack.remove(undoStack.size()-1); // Retrieve the last saved canvas state from the undo stack to undo the previous action
  
    canvas.beginDraw();
    canvas.image(previous, 0, 0); // Draw the previous canvas state to restore it on the canvas
    canvas.endDraw();
  }
  
  // Redo
  if ((key == 'y' || key == 'Y') && redoStack.size() > 0) {
  undoStack.add(canvas.get()); // Save a snapshot of the current canvas state to the undo stack

  PImage next = redoStack.remove(redoStack.size()-1); // Retrieve the last saved canvas state from the redo stack to redo the action

  canvas.beginDraw();
  canvas.image(next, 0, 0); // Draw the retrieved canvas state onto the canvas to restore it
  canvas.endDraw();
  }
}

// Function that clears the canvas
void resetCanvas() {
  canvas.beginDraw();
  canvas.background(0); // Set the background to black
  canvas.endDraw(); 
}
