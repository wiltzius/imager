// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="shouty.jpg"; */

//PImage img;

PImage img;

int canvas_x = 800;
int canvas_y = 800;

int block_size;

String color2str(color c) {
  return "(" + red(c) + "," + green(c) + "," + blue(c) + ")"; 
}

class MPoint {

  public int x;
  public int y;

  MPoint(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public String toString() {
    return "(" + this.x + ", " + this.y + ")";
  }

}

class Block {

  public int x;
  public int y;
  public int w;
  public int h;
  public MPoint topLeft;
  public MPoint topRight;
  public MPoint bottomLeft;
  public MPoint bottomRight;
  
  // Handle to the image this block represents a view over
  public PImage img;
  // Indexes into the image's 1-D pixel array of all pixels covered by this block 
  public int[] pixelIndexes;
  

  private void populatePoints() {
    this.topLeft = new MPoint(this.x, this.y);
    this.topRight = new MPoint(this.x + this.w, this.y);
    this.bottomLeft = new MPoint(this.x, this.y + this.h);
    this.bottomRight = new MPoint(this.x + this.w, this.y + this.h);
  }

  private void populatePixelIndexes() {
    this.pixelIndexes = new int[this.w * this.h];
    int counter = 0;
    for (int i = this.x; i < this.x + this.w; i++) {
      for (int j = this.y; j < this.y + this.h; j++) {
        this.pixelIndexes[counter] = i + (j * this.img.width);
        counter++;
      }
    }
  }

  public String toString() {
    //return this.topLeft + " to " + this.bottomRight + " / " + this.x + this.y + this.w + this.h;
    return "x: " + this.x + ", y: " + this.y + ", width: " + this.w + ", height: " + this.h;
  }

  private void sanityCheck() {
    println(this.x + ", " + this.y + ", " + this.w + ", " + this.h); 
    println("topLeft: " + this.topLeft);
    println("topRight: " + this.topRight);
    println("bottomLeft: " + this.bottomLeft);
    println("bottomRight: " + this.bottomRight);
  }
/*
  Block(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    //this.populatePoints();
    this.populatePixelIndexes();
  }*/
  
  Block(int x, int y, int sideLength, PImage img) {
    this.x = x;
    this.y = y;
    this.w = sideLength;
    this.h = sideLength;
    //this.populatePoints();
    this.img = img;
    this.populatePixelIndexes();
  }
  
}

class BlockProcessor {

  public int block_size;
  public PImage img;
  
  private Block BlockFactory(int x, int y) {
    return new Block(x, y, this.block_size, this.img);
  }
  
  // No default constructor
  private BlockProcessor() {}
  
  public BlockProcessor(int block_size, PImage img) {
    this.block_size = block_size;
    this.img = img;
    this.img.loadPixels();
  }

  // Averages color in this block.
  private color color_average2(Block b) {
    int red = 0, blue = 0, green = 0;
    for (int i = 0; i < b.pixelIndexes.length; i++) {
      color c = this.img.pixels[b.pixelIndexes[i]];
      red += red(c);
      blue += blue(c);
      green += green(c);
    }
    int total = b.pixelIndexes.length;
    color toReturn = color(red / total, green / total, blue / total);
    return toReturn;
  }

  private void setRange(Block b, color value) {
    println("Setting range on pixels ", min(b.pixelIndexes), " through ", max(b.pixelIndexes), " (", b.pixelIndexes.length, " pixels) ");
    println("Setting to ", color2str(value));
    for(int i = 0; i < b.pixelIndexes.length; i++) {
      this.img.pixels[b.pixelIndexes[i]] = value;
    }
  }

  public void process_as_blocks() {
    for (int i = 0; i < img.width - this.block_size; i += this.block_size) {
      for (int j = 0; j < img.height - this.block_size; j += this.block_size) {
        Block b = this.BlockFactory(i, j);
        println(b);
        color color_average = this.color_average2(b);
        this.setRange(b, color_average);
      }
    }
  }
  
}

/* convolution matrix */
float[][] matrix = { { -1, -1, -1 },
                     { -1,  9, -1 },
                     { -1, -1, -1 } };

/*
  Uses the block size as the kernel size
 */
class OverlappingBlockProcessor extends BlockProcessor {
  
  public void process_as_blocks() {
    // iterate over all pixels, ensuring a full block size margin (i.e. skipping edges)
    for (int i = this.block_size; i < width - this.block_size; i++) {
      for (int j = this.block_size; j < height - this.block_size; j++) {
         
      }
    }
  }

}


void setup() {
  size(800, 800);
  img = loadImage("image2.jpg");;
  noLoop();
}

void draw() {
  background(0);
  int block_size = 33;
  int num_blocks_wide = (img.width / block_size);  // NB integer division
  int num_blocks_high = (img.height / block_size);
  int trimmed_width = block_size * num_blocks_wide;
  int trimmed_height = num_blocks_high * block_size;
  float aspect_ratio = (float(img.width) / float(img.height));
  
  BlockProcessor bp = new BlockProcessor(block_size, img);
  bp.process_as_blocks();
  bp.img.updatePixels();
  image(bp.img, 0, 0, width * aspect_ratio, height);
}





