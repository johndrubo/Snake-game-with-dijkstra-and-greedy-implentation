int fps = 300;

// Board 36x27
int horSqrs = 36;
int verSqrs = 27;
// Board 12x12
// int horSqrs = 12;
// int verSqrs = 12;

// Window mode for 36x27 board
int scl = 22;
// Full-screen mode, 36x27 board
// int scl = 28;
// Full-screen mode, 12x12 board
// int scl = 63;

// Colors
int bgcol = color(44, 47, 124);
int gridcol = color(114, 119, 255);
int snakecol = color(0, 249, 124);
int foodcol = color(255, 48, 69);
int searchcol = color(152, 69, 209);
int shortpathcol = color(242, 149, 29);
int longpathcol = color(255, 250, 0);

boolean notRenderSearchKey = true; // show search (true) or hide it (false)
boolean renderingMainSearch = false;
boolean gamePaused = false;
/* Note that there are two search modes: the simple one that only performs
   Dijkstra's search and doesn't complete the game, and a more complex one
   that, in addition to Dijkstra's search, checks if the snake becomes trapped.
   This variable chooses which one to use, and note that in keyPressed() there's a key
   to switch between them during the game */
boolean justDijkstra = false;

Snake snake;
PVector food_pos = new PVector(floor(random(horSqrs)) * scl, floor(random(verSqrs)) * scl);

void settings() {
  size(scl * horSqrs + 1, scl * verSqrs + 1);
}

void setup() {
  // For full-screen mode
  // background(bgcol);
  // fullScreen();
  // pushMatrix();
  // translate(170, 6);

  grid(gridcol);
  snake = new Snake(false);
  updateFood();
  renderFood();

  //popMatrix(); // For full-screen mode
}

int p = 0;
void draw() {
  if (!gamePaused) {
    if (notRenderSearchKey) {
      renderingMainSearch = false;
    }
    if (!renderingMainSearch) {
      frameRate(fps);
    }
    // For full-screen mode
    // pushMatrix();
    // translate(170, 6);

    if (!renderingMainSearch) { // If the search is not being rendered, advance the game normally...
      background(bgcol);
      grid(gridcol);
      snake.update();
      updateFood();
      snake.search();
      p = 0;
    } else { // ...but if the search is being rendered...
      if (snake.justAte) {
        snake.controller.renderMainSearch(); // first render the main search (purple with orange path)
        /* and if the main search is already rendered and the snake is trapped
           and it needs to find the longest path... */
        if (snake.controller.mainSearch.size() == 0 && snake.controller.inLongestPath) {
          p++;
          stroke(longpathcol);
          strokeWeight(4);
          // ...draw the entire line of the longest path (this is the yellow line that appears occasionally)
          line(snake.pos[0].x + scl / 2, snake.pos[0].y + scl / 2, snake.controller.longestPath.get(0).x * scl + scl / 2, snake.controller.longestPath.get(0).y * scl + scl / 2);
          for (int i = 0; i < snake.controller.longestPath.size() - 1; i++) {
            line(snake.controller.longestPath.get(i).x * scl + scl / 2, snake.controller.longestPath.get(i).y * scl + scl / 2, snake.controller.longestPath.get(i + 1).x * scl + scl / 2, snake.controller.longestPath.get(i + 1).y * scl + scl / 2);
          }
          strokeWeight(1);
        }
      } else {
        renderingMainSearch = false;
      }
    }
    snake.render();
    renderFood();
    // popMatrix(); // For full-screen mode
    if (snake.controller.mainSearch.size() == 0 && snake.controller.inLongestPath && p == 2) {
      delay(3000);
    }
  }
}

// This is for drawing the grid
void grid(color col) {
  for (int i = 0; i < horSqrs + 1; i++) {
    stroke(col);
    line(scl * i, 0, scl * i, verSqrs * scl);
  }
  for (int i = 0; i < verSqrs + 1; i++) {
    stroke(col);
    line(0, scl * i, horSqrs * scl, scl * i);
  }
}

/*
  I could have created a class for the food, but I preferred to keep everything
  in these two functions
*/
void updateFood() {
  if (snake.ateFood()) {
    boolean match = true;
    while (match) {
      match = false;
      food_pos.x = floor(random(horSqrs)) * scl;
      food_pos.y = floor(random(verSqrs)) * scl;
      // This is to make sure the food doesn't appear where the snake's body is
      for (int i = 0; i < snake.pos.length; i++) {
        if (food_pos.x == snake.pos[i].x && food_pos.y == snake.pos[i].y) {
          match = true;
        }
      }
    }
  }
}
void renderFood() {
  fill(foodcol);
  noStroke();
  rect(food_pos.x + 1, food_pos.y + 1, scl - 1, scl - 1);
}

boolean isOutsideWorld(PVector pos) {
  if (pos.x >= scl * horSqrs || pos.x < 0 || pos.y >= scl * verSqrs || pos.y < 0) {
    return true;
  }
  return false;
}

// D: use only Dijkstra's search, R: show search, K: pause, J: slow down, L: speed up
void keyPressed() {
  if (key == 'd') {
    justDijkstra = !justDijkstra;
  }
  if (key == 'r') {
    notRenderSearchKey = !notRenderSearchKey;
  }
  if (key == 'k') {
    gamePaused = !gamePaused;
  }
  if (key == 'l') {
    switch (fps) {
      case 5:
        fps = 15;
      case 15:
        fps = 30;
        break;
      case 30:
        fps = 100;
        break;
      case 100:
        fps = 200;
        break;
      case 200:
        fps = 300;
        break;
      default:
        break;
    }
  }
  if (key == 'j') {
    switch (fps) {
      case 300:
        fps = 200;
        break;
      case 200:
        fps = 100;
        break;
      case 100:
        fps = 30;
      case 30:
        fps = 15;
        break;
      case 15:
        fps = 5;
        break;
      default:
        break;
    }
  }
}
