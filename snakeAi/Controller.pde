/*
   Here is all the logic of artificial intelligence
   including the implementation of search algorithms
   like Dijkstra.
*/

public class Controller {

  boolean inLongestPath = false;
  ArrayList<PVector> longestPath = new ArrayList<PVector>();
  ArrayList<PVector> mainSearch = new ArrayList<PVector>();
  ArrayList<PVector> mainPathGeneral = new ArrayList<PVector>();

  /* Every frame is executed, this is the main function
      from which the other lookups are controlled */
  void control() {
    mainSearch = new ArrayList<PVector>(); /* This array is used for the lookup for a main path to the food using dijkstra */
    mainPathGeneral = dijkstra(snake, int(food_pos.x/scl), int(food_pos.y/scl), true);

    if(mainPathGeneral.size() > 0) { //if the path is found
      if(justDijkstra) { //if it is just for dijsktra
        int[] mainHead = {int(snake.pos[0].x/scl), int(snake.pos[0].y/scl)};
        chooseSpeed(snake, mainPathGeneral.get(1), mainHead); //choose normal mode
      } else { //but if more complex search method is on, checks if the snake eats itself
        Snake virtualSnake = snake.copy(); // creates a virtual version of the snake and emulates the shortest path to go there, snakes is designated by i and the nodes are designated from 1 to 6kk0
        int[] currentHead = {0,0};

        
        for (int i = 1; i < mainPathGeneral.size(); ++i) {
          currentHead[0] = int(virtualSnake.pos[0].x/scl);
          currentHead[1] = int(virtualSnake.pos[0].y/scl);
          chooseSpeed(virtualSnake, mainPathGeneral.get(i), currentHead);
          if(i == mainPathGeneral.size() - 1) {
            virtualSnake.eatsFood();
          }
          virtualSnake.update();
        }

        //once reached there virtually, the snake queues itself to go there in reality
        
        ArrayList<PVector> tracebackBack = dijkstra(virtualSnake, int(virtualSnake.pos[virtualSnake.pos.length-1].x/scl), int(virtualSnake.pos[virtualSnake.pos.length-1].y/scl), false);
        int[] mainHead = {int(snake.pos[0].x/scl), int(snake.pos[0].y/scl)};

        if(tracebackBack.size() > 0) { /* If it does find its way to the queue
            It won't lock and you can choose the normal path you found at the beginning*/
          chooseSpeed(snake, mainPathGeneral.get(1), mainHead);
          inLongestPath = false;
        } else { // But if it doesn't find it, it searchs and follows the longest one until it stops locking
          if(inLongestPath && longestPath.size() > 1) { // If you were already traversing the longest path in the previous frame
            chooseSpeed(snake, longestPath.get(1), mainHead); //it just continues on it
            longestPath.remove(0);
          } else { // but if it wasn't traversing it
            longestPathHeadTail(); // find longest path to the tail
          }
        }
      }
    } else { // But if it doesn't find the main path in the first Dijsktra...
      if(justDijkstra) { //and if it's in just Dijkstra mode, it rotates if it's about to crash
        if(snake.isInBody(PVector.add(snake.pos[0], snake.vel)) || isOutsideWorld(PVector.add(snake.pos[0], snake.vel))) {
          PVector rotateRight = snake.vel.copy().rotate(HALF_PI);
          rotateRight.x = int(rotateRight.x);
          rotateRight.y = int(rotateRight.y);
          PVector rotateLeft = snake.vel.copy().rotate(-HALF_PI);
          rotateLeft.x = int(rotateLeft.x);
          rotateLeft.y = int(rotateLeft.y);
          if(!snake.isInBody(new PVector(snake.pos[0].x + rotateRight.x, snake.pos[0].y + rotateRight.y)) && !isOutsideWorld(new PVector(snake.pos[0].x + rotateRight.x, snake.pos[0].y + rotateRight.y))) {
            println("rotating to the right");
            snake.vel = rotateRight;
          } else if(!snake.isInBody(new PVector(snake.pos[0].x + rotateLeft.x, snake.pos[0].y + rotateLeft.y)) && !isOutsideWorld(new PVector(snake.pos[0].x + rotateLeft.x, snake.pos[0].y + rotateLeft.y))) {
            println("rotating left");
            snake.vel = rotateLeft;
          } else {
            println("There is no place to rotate");
          }
        }
      } else {/*and if not in justDijsktra mode
            Same logic as before, search longest to queue. this is different
            from the previous time because here it is done when it did not find the main path,
            while in the other it is done when if, if you follow the main path,
            it would end up shutting down. */
        int[] mainHead = {int(snake.pos[0].x/scl), int(snake.pos[0].y/scl)};
        if(inLongestPath && longestPath.size() > 1) {
          chooseSpeed(snake, longestPath.get(1), mainHead);
          longestPath.remove(0);
        } else {
          longestPathHeadTail();
        }
      }
    }
  }

  /* Dijkstra search, used for both snake search*/
  ArrayList<PVector> dijkstra(Snake currentSnake, int destinationX, int destinationY, boolean print) {
    /* Node is each square on the map, measures its value from the nodes distances  to the
        head of the serpent.*/
    int[][] nodes = new int[horSqrs][verSqrs];
    ArrayList<PVector> queue = new ArrayList<PVector>();
    boolean[][] checked = new boolean[horSqrs][verSqrs];

    // First node, head of the snake
    int[] firstNode = {int(currentSnake.pos[0].x/scl), int(currentSnake.pos[0].y/scl)};
    PVector currentNode = new PVector(currentSnake.pos[0].x, currentSnake.pos[0].y);

    // Initialize all nodes with an infinite value, except the first one, which is 0
    for (int i = 0; i < horSqrs; ++i) {
      for (int ii = 0; ii < verSqrs; ++ii) {
        if(firstNode[0] != i || firstNode[1] != ii) {
          nodes[i][ii] = Integer.MAX_VALUE;
          checked[i][ii] = false;
        } else {
          nodes[i][ii] = 0;
          checked[i][ii] = true;
        }
      }
    }

   // Start adding nodes to the queue that evaluates them one by one to assign values
    queue.add(new PVector(firstNode[0], firstNode[1]));
    boolean somethingInQueue = true;
    int i = 0;

    /* In this cycle the values of all the nodes are filled, that is, the distance calculates
           all the squares on the map that it can reach. for this
        each of the nodes is checked. */
    while(somethingInQueue) {
      i++;

      int horIndex = int(queue.get(0).x);
      int verIndex = int(queue.get(0).y);
      
      int value = Integer.MAX_VALUE;

      /* Each node is checked for the four nodes on its sides and the value is assigned depending on
          the one with the smallest */
      value = checkSideNode(horIndex, 0, horIndex-1, verIndex, value, nodes, queue, currentSnake); // left
      value = checkSideNode(-horIndex, 1-horSqrs, horIndex+1, verIndex, value, nodes, queue, currentSnake); // right
      value = checkSideNode(verIndex, 0, horIndex, verIndex-1, value, nodes, queue, currentSnake); //up
      value = checkSideNode(-verIndex, 1-verSqrs, horIndex, verIndex+1, value, nodes, queue, currentSnake); // down

      queue.remove(0); // remove the current node from the queue because it is the one being checked
      
      if(int(horIndex) != firstNode[0] || int(verIndex) != firstNode[1]) { // If the current node is not the first...
        if(!renderingMainSearch) {
          mainSearch.add(new PVector(horIndex, verIndex)); // This array is only used to search every time it eats
        }
        nodes[horIndex][verIndex] = value; // every node is assigned a value
        checked[horIndex][verIndex] = true;
      }

      // Print a version of the game map to the console with the value of the nodes
      if(queue.size() == 0) {
        somethingInQueue = false;
        if(print) {
          println("===================================================");
          println("===================================================");
          printScreen(nodes);
        }
      }
    }

  /* Having assigned all nodes a value, start returning from the node
        with food (destinationX, Y) to the head of the snake */
    ArrayList<PVector> tracebackNodes = new ArrayList<PVector>();
    int[] tracebackNode = {destinationX, destinationY};
    tracebackNodes = new ArrayList<PVector>();
    tracebackNodes.add(new PVector(tracebackNode[0], tracebackNode[1]));
    boolean closed = false;
  
    
    while(tracebackNode[0] != firstNode[0] || tracebackNode[1] != firstNode[1]) {
      PVector move = lowestNextTo(tracebackNode[0], tracebackNode[1], nodes);
      if(move.x == -1 && move.y == -1) {
        return new ArrayList<PVector>();
      }
      tracebackNodes.add(0, move);
      tracebackNode[0] = int(move.x);
      tracebackNode[1] = int(move.y);
    }

    renderingMainSearch = true;// when the search is done, the following frames are used to draw it
    return tracebackNodes; // if it doesn't find a path, this returns empty
  }

  int checkSideNode(int checked, int checkTo, int checkHor, int checkVer, int cValue, int[][] nodes, ArrayList<PVector> queue, Snake cSnake) {
    if(checked > checkTo) { // Check that they are inside the virtual world inside the console
      if(nodes[checkHor][checkVer] < Integer.MAX_VALUE) { // And that its value is not i
        if(nodes[checkHor][checkVer] < cValue) {// If the value of the side node is less than the central node
          return nodes[checkHor][checkVer] + 1;
        }
      } else { // but if its value is infinite
        if(!cSnake.isInBody(checkHor, checkVer)) {
          if(!queue.contains(new PVector(checkHor, checkVer))) {
            queue.add(new PVector(checkHor, checkVer)); /* is added to the queue, because it means that it is not checked
              with this last line make sure that the queue goes through all the nodes*/
          }
        }
      }
    }
    return cValue;
  }

  // Check which is the node with the lowest value to the one that has the coords. x,y
  PVector lowestNextTo(int x, int y, int[][] nodes) {
    int lowestXInd = 0;
    int lowestYInd = 0;
    int lowestValue = Integer.MAX_VALUE;
    boolean closed = true;

    if(x > 0) {
      if(nodes[x-1][y] < lowestValue) {
        closed = false;
        lowestValue = nodes[x-1][y] + 1;
        lowestXInd = x-1;
        lowestYInd = y;
      }
    }
    if(x < horSqrs - 1) {
      if(nodes[x+1][y] < lowestValue - 1) {
        closed = false;
        lowestValue = nodes[x+1][y] + 1;
        lowestXInd = x+1;
        lowestYInd = y;
      }
    }
    if(y > 0) {
      if(nodes[x][y-1] < lowestValue - 1) {
        closed = false;
        lowestValue = nodes[x][y-1] + 1;
        lowestXInd = x;
        lowestYInd = y-1;
      }
    }
    if(y < verSqrs - 1) {
      if(nodes[x][y+1] < lowestValue - 1) {
        closed = false;
        lowestValue = nodes[x][y+1] + 1;
        lowestXInd = x;
        lowestYInd = y+1;
      }
    }
    
    if(closed) {
      return new PVector(-1, -1);
    }
    return new PVector(lowestXInd, lowestYInd);
    
  }

/* Find the longest path to the queue. For this look for the way
      shorter with Dijkstra, and lengthens it by steps */
  void longestPathHeadTail() {
    ArrayList<PVector> path = dijkstra(snake, int(snake.pos[snake.pos.length-1].x/scl), int(snake.pos[snake.pos.length-1].y/scl), false);

    if(path.size() > 0) {
      /* This algorithm consists of traversing the path found by Dijkstra from the
          head of the serpent to the tail, and if it finds two nodes in said path
          consecutive in the same column with two free spaces to the right or the
          left, or if it finds two consecutive nodes in the same row with two spaces
          free up or down, then it goes n either direction. Do
          that over and over again until there is no more room. */
      boolean aPairFound = true;
      while(aPairFound) {
        aPairFound = false;
        for (int i = 0; i < path.size()-1; ++i) {
          //Two nodes in the same column
          if(path.get(i).x == path.get(i+1).x) {
            //Expand to the left
            if(areValidForLongestPath(path.get(i).x-1, path.get(i).y, path.get(i+1).x-1, path.get(i+1).y, path, snake)) {
              path.add(i+1, new PVector(path.get(i).x-1, path.get(i).y));
              path.add(i+2, new PVector(path.get(i+2).x-1, path.get(i+2).y));
              aPairFound = true;
              break;
            //Expand to the right
            } else if(areValidForLongestPath(path.get(i).x+1, path.get(i).y, path.get(i+1).x+1, path.get(i+1).y, path, snake)) {
              path.add(i+1, new PVector(path.get(i).x+1, path.get(i).y));
              path.add(i+2, new PVector(path.get(i+2).x+1, path.get(i+2).y));
              aPairFound = true;
              break;
            }
          //Two nodes in the same row
          } else if(path.get(i).y == path.get(i+1).y) {
            //go down
            if(areValidForLongestPath(path.get(i).x, path.get(i).y+1, path.get(i+1).x, path.get(i+1).y+1, path, snake)) {
              path.add(i+1, new PVector(path.get(i).x, path.get(i).y+1));
              path.add(i+2, new PVector(path.get(i+2).x, path.get(i+2).y+1));
              aPairFound = true;
              break;
            ////go up
            } else if(areValidForLongestPath(path.get(i).x, path.get(i).y-1, path.get(i+1).x, path.get(i+1).y-1, path, snake)) {
              path.add(i+1, new PVector(path.get(i).x, path.get(i).y-1));
              path.add(i+2, new PVector(path.get(i+2).x, path.get(i+2).y-1));
              aPairFound = true;
              break;
            }
          }
        }
      }

      // Having the longest path, move in the direction that follows it
      int[] mainHead = {int(snake.pos[0].x/scl), int(snake.pos[0].y/scl)};
      chooseSpeed(snake, path.get(1), mainHead);
      path.remove(0);
      longestPath = path;
      inLongestPath = true;
    } else {
      /* This for some reason never runs which is weird
          but I'm too lazy to figure out why */
      println("No head to tail contact");
      delay(30000);
      System.exit(0);
    }
  }

  // Check that the two nodes being checked are empty
  boolean areValidForLongestPath(float x1, float y1, float x2, float y2, ArrayList<PVector> path, Snake cSnake) {
    if (!path.contains(new PVector(x1, y1)) && 
        !path.contains(new PVector(x2, y2)) && 
        !isOutsideWorld(new PVector(x1*scl, y1*scl)) &&
        !isOutsideWorld(new PVector(x2*scl, y2*scl)) && 
        !cSnake.isInBody(int(x1), int(y1)) &&
        !cSnake.isInBody(int(x2), int(y2)) &&
        (x1 != int(food_pos.x/scl) || y1 != int(food_pos.y/scl)) &&
        (x2 != int(food_pos.x/scl) || y2 != int(food_pos.y/scl))) {
      return true;
    }
    return false;
  }

  // Function that renders the main search (runs for several frames)
  void renderMainSearch() {
    if(mainSearch.size() > 0) {
      frameRate(2000);
      fill(searchcol);
      noStroke();
      rect(mainSearch.get(0).x*scl + 1, mainSearch.get(0).y*scl + 1, scl - 1, scl - 1);
      if(mainSearch.get(0).x*scl == food_pos.x && mainSearch.get(0).y*scl == food_pos.y) {
        fill(shortpathcol);
        for (PVector place : mainPathGeneral) {
          rect(place.x*scl + 1, place.y*scl + 1, scl - 1, scl - 1);
        }
      }
      mainSearch.remove(0);
    } else {
      renderingMainSearch = false;
    }
  }

  // Choose the direction of movement of the snake
  void chooseSpeed(Snake cSnake, PVector move, int[] cHead) {

    int horMove = int(move.x) - cHead[0];
    int verMove = int(move.y) - cHead[1];

    if(horMove == -1 && verMove == 0) {
      cSnake.vel.x = -scl;
      cSnake.vel.y = 0;
    } else if(horMove == 1 && verMove == 0) {
      cSnake.vel.x = scl;
      cSnake.vel.y = 0;
    } else if(horMove == 0 && verMove == -1) {
      cSnake.vel.x = 0;
      cSnake.vel.y = -scl;
    } else if(horMove == 0 && verMove == 1) {
      cSnake.vel.x = 0;
      cSnake.vel.y = scl;
    }
  }

 // Print the values of each map node
  void printScreen(int[][] nodes) {
    for (int o = 0; o < verSqrs; ++o) {
      for (int oo = 0; oo < horSqrs; ++oo) {
        if(nodes[oo][o] == Integer.MAX_VALUE) {
          print("i  ");
        } else {
          if(nodes[oo][o] < 10) {
            print(nodes[oo][o] + "  ");
          } else if(nodes[oo][o] < 100) {
            print(nodes[oo][o] + " ");
          }
        }
      }
      print('\n');
    }
  }
}
