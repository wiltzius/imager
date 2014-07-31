// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="shouty.jpg"; */

//PImage img;

PImage img = loadImage("shouty.jpg");

int canvas_x = 800;
int canvas_y = 800;

int block_size;

class Point {

  int x;
  int y;

  Point(int x, int y) {
    this.x = y;
    this.y = y;
  }

}

class Block {

  public int x;
  public int y;
  public int w;
  public int h;
  public Point topLeft;
  public Point topRight;
  public Point bottomLeft;
  public Point bottomRight;
  // All the indexes into a Processing-style 1D pixel array covered by this block
  public int[] pixelIndexes;

  private void populatePoints() {
    this.topLeft = new Point(x, y);
    this.topRight = new Point(x + w, y);
    this.bottomLeft = new Point(x, y + h);
    this.bottomRight = new Point(x + w, y + h);
  }

  private void populatePixelIndexes() {
    this.pixelIndexes = new int[this.w * this.h];
    int counter = 0;
    for (int i = this.topLeft.x; i < this.bottomRight.x; i++) {
      for (int j = this.topLeft.y; j < this.bottomRight.y; j++) {
        this.pixelIndexes[counter] = i + j * this.w;
        counter++;
      }
    }
  }

  Block(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.populatePoints();
    this.populatePixelIndexes();
  }
  
  Block(int x, int y, int sideLength) {
    this.x = x;
    this.y = y;
    this.w = sideLength;
    this.h = sideLength;
    this.populatePoints();
    this.populatePixelIndexes();
  }
  
}
/*
class OverlappingBlockProcessor {

    OverlappingBlockProcessor() {
    }

}*/

class BlockProcessor {

  public int block_size;
  
  private Block BlockFactory(int x, int y) {
    return new Block(x, y, block_size);
  }
  
  BlockProcessor(int block_size) {
    this.block_size = block_size;
  }

  // Averages brightness in this block.
  private color color_average2(Block b) {
    int r = 0, b = 0, g = 0;
    println(b.x);
    for (int i = 0; i < b.pixelIndexes.length; i++) {
      color c = pixels[i];
      r += red(c);
      b += blue(c);
      g += green(c);
    }
    int total = b.pixelIndexes.length;
    color toReturn = color(r / total, g / total, b / total);
    return toReturn;
  }

  private void setRange(Block b, color value) {
    for(int i = 0; i < b.pixelIndexes.length; i++) {
      pixels[i] = value;
    }
  }

  public void process_as_blocks() {
    for (int i = 0; i < width; i += this.block_size) {
      for (int j = 0; j < height; j += this.block_size) {
        //PImage block_img = get(i, j, this.block_size, this.block_size);
        Block b = new Block(i, j, this.block_size);
        color color_average = this.color_average2(b);
        //color color_average = #FFFF33;
        this.setRange(b, color_average);
      }
    }
  }
  
}

void setup() {
  size(800, 800);
  noLoop();
  img = loadImage("shouty.jpg");
}

void draw() {
  background(0);
  int canvas_x = 800;
  int canvas_y = 800;
  image(img, 0, 0, 800, 800);
  loadPixels();
  BlockProcessor bp = new BlockProcessor(10);
  bp.process_as_blocks();
  
  updatePixels();
  
}






