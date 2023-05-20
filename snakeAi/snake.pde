/*
   For the most part this is a standard Snake class for
   this game. The only difference is the controller object
   which is the one that applies the search
*/
class Snake {
  int length = 0;
  boolean justAte = false;
  Controller controller = new Controller();
  PVector[] pos = new PVector[1];// array of snake body positions
  PVector vel = new PVector(1,0);
  PVector prev_head = new PVector(0,0);
  
/* The virtual snake is for when you are doing the search,
      that a virtual is created in the console that is the one that makes the tour that checks
      if the path is free and console is cleared out once it finds the target */
  Snake(boolean isVirtual) {
    vel.mult(scl);
    pos[0] = new PVector(floor(horSqrs/2)*scl,floor(verSqrs/2)*scl);
    // render only if it is virtual
    if(!isVirtual) {
      this.square(pos[0].x, pos[0].y);
    }
  }
  
  /* Executes every frame, this is all the main logic of the Snake game */
  void update() {
    justAte = false;
    prev_head = pos[0].get();
    pos[0].add(vel);
    this.checkEatFood();
    this.checkBoundaries();
    this.move();
    this.checkCollBody();
  }

 // Executes on every frame, this is the search
  void render() {
    for(int i = 0; i < this.pos.length-1; i++) {
      square(this.pos[i].x, this.pos[i].y);
     /* All that follows is to draw a little rectangle between
          two body squares, this is for the snake to
          it looks continuous and not like many separate squares */
       
      if(pos[i].x == pos[i+1].x) {
       // Array increases down
        if(pos[i].y < pos[i+1].y) {
          rect(pos[i].x + 2, pos[i].y + scl - 1, scl - 3, 3);
        }
        // array increase up
        if(pos[i].y > pos[i+1].y) {
          rect(pos[i].x + 2, pos[i+1].y + scl - 1, scl - 3, 3);
        }
      }
      // Same row
      if(pos[i].y == pos[i+1].y) {
        // Array increases to the right
        if(pos[i].x < pos[i+1].x) {
          rect(pos[i].x + scl - 1, pos[i].y + 2, 3, scl - 3);
        }
        // Array increases to the left
        if(pos[i].x > pos[i+1].x) {
          rect(pos[i+1].x + scl - 1, pos[i].y + 2, 3, scl - 3);
        }
      }
    }
    square(pos[pos.length-1].x, pos[pos.length-1].y); //  body part as an i value
  }
  
  // Here the body of the snake moves
  void move() {
    PVector previous = this.prev_head.get();
    PVector previous_copy = this.prev_head.get(); 
    for(int i = 1; i < this.pos.length; i++) {
      previous = pos[i];
      pos[i] = previous_copy;
      previous_copy = previous;
    }
  }

  /* Self explanatory, but this is the important function. It is called in
      the main draw() */
  void search() {
    this.controller.control();
  }
  
  void checkEatFood() {
    if(this.pos[0].x == food_pos.x && this.pos[0].y == food_pos.y) { 
      this.eatsFood();
    }
  }
  
 // make the snake bigger after eating
  void eatsFood() {
    if(this.pos.length == 1) {
      this.pos = (PVector[])append(this.pos, new PVector(this.prev_head.x, this.prev_head.y));
    } else {
      this.pos = (PVector[])append(this.pos, new PVector(this.pos[this.pos.length - 1].x, this.pos[this.pos.length - 1].y));
    }
  }

  /* I think the following are self explanatory */
  
  boolean ateFood() {
    if(this.pos[0].x == food_pos.x && this.pos[0].y == food_pos.y) {
      justAte = true;
      return true;
    }
    return false;
  }
  
  void died() {
    this.pos = new PVector[1];
    this.pos[0] = new PVector(floor(random(horSqrs))*scl, floor(random(verSqrs))*scl);
  }
  
  void checkBoundaries() {
    if(isOutsideWorld(pos[0])) {
      this.died();
    }
  }
  
  void checkCollBody() {
    if(isInBody(this.pos[0])) {
      this.died();
    }
  }

  boolean isInBody(int x, int y) {
    for(int i = 1; i < this.pos.length; i++) {
      if(x*scl == this.pos[i].x && y*scl == this.pos[i].y) {
        return true;
      }
    }
    return false;
  }

  boolean isInBody(PVector position) {
    return isInBody(int(position.x/scl), int(position.y/scl));
  }
  
  void square(float x, float y) {
    noStroke();
    fill(snakecol);
    rect(x + 2, y + 2, scl - 3, scl - 3);
  }

  // To make a virtual copy of the snake in the console
  Snake copy() {
    Snake copy = new Snake(true);
    copy.pos[0] = pos[0].copy();
    for (int i = 1; i < pos.length; ++i) {
      copy.pos = (PVector[])append(copy.pos, pos[i].copy());
    }
    copy.vel = vel.copy();
    copy.prev_head = prev_head.copy();

    return copy;
  }
}
