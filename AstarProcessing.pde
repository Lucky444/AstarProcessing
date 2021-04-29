grid _grid;
AstarManager _aMan;

int frameRate = 0;
int frames = 0;

boolean start;
String finished = "";
boolean fin = false;

void setup() {
  size(1000, 1000);
  background(255, 0, 255);

  _grid = new grid(10, 10);
  _aMan = new AstarManager(_grid);
}

void draw() {
  if(mousePressed){
     _grid.handleInput_MOUSE(); 
  }
  
  rectMode(CORNER);
  _grid.update();
  if (frames > frameRate) {
    frames = 0;
    _aMan.startPathFinder();
  } else if (start) {
    frames ++;
  }
  if (fin) {
    fill(0);
    fill(100);
    textSize(45);
    textAlign(RIGHT);
    text(finished, width-width/50, height/10);
  }
}

void keyPressed() {
  _grid.handleInput_KEYBOARD();
}

//----------------------------------Grid Drawing
class grid {
  gridCell[][] cells;
  int gridW, gridH;
  protected int cellW, cellH;
  protected int selectedType = 0;

  public grid(int grid_width, int grid_height) {
    gridW = grid_width;
    gridH = grid_height;

    cellW = width/grid_width;
    cellH = height/grid_height;

    populateGrid();
  }

  void populateGrid() {

    cells = new gridCell[gridH][gridW];

    for (int y = 0; y < gridH; y ++) {
      for (int x = 0; x < gridW; x ++) {
        cells[x][y] = new gridCell(x, y, 1, this);
      }
    }
  }

  public gridCell get(int X, int Y) {
    return(cells[X][Y]);
  }

  protected void reset() {
    for (int y = 0; y < gridH; y ++) {
      for (int x = 0; x < gridW; x ++) {
        cells[x][y].paint(1);
        _aMan.checkCellState(cells[x][y]);
      }
    }
  }

  public void update() {
    background(0);
    for (int y = 0; y < gridH; y ++) {
      for (int x = 0; x < gridW; x ++) {
        cells[x][y].update();
      }
    }
  }

  public void handleInput_MOUSE() {
    for (int y = 0; y < gridH; y ++) {
      for (int x = 0; x < gridW; x ++) {
        if (cells[x][y].isHovered) {
          if (selectedType == 0) {
            _aMan.setStart(cells[x][y]);
          } else if (selectedType == 3) {
            _aMan.setFinish(cells[x][y]);
          } else {
            cells[x][y].paint(selectedType);
            _aMan.checkCellState(cells[x][y]);
          }
        }
      }
    }
  }

  public void handleInput_KEYBOARD() {
    switch(key) {
      case('r'):
      reset();
      break;
      case('1'):
      selectedType = 0;
      break;
      case('2'):
      selectedType = 2;
      break;
      case('3'):
      selectedType = 3;
      break;
      case(RETURN):
      if (_aMan.startCell != null && _aMan.finishCell != null) {
        _aMan.startPathFinder();
      }
      break;
      case(' '):
      if (_aMan.startCell != null && _aMan.finishCell != null) {
        start = true;
      }
      break;
    }
  }
}

class gridCell {
  //-- Normal variables
  public boolean isHovered = false; 
  public int X;
  public int Y;
  public int type; //0 = start, 1 = normal, 2 = blocked, 3 = end, 4 = open, 5 = closed, 6 == way
  grid parent;
  color c = color(255);

  //-- The A* shit
  protected int fCost = 0;
  protected int gCost = 0;
  protected int hCost = 0;

  public gridCell(int X, int Y, int type, grid parent) {
    this.X = X;
    this.Y = Y;
    this.type = type;
    this.parent = parent;

    drawCell();
  }

  protected void calculateCost(gridCell reference) {
    if ((X == reference.X && Y != reference.Y) || (Y == reference.Y && X != reference.X)) {
      gCost = 10 + reference.gCost;
    } else {
      gCost = 14 + reference.gCost;
    }

    //hCost
    int distY = Math.abs(Y - _aMan.finishCell.Y);
    int distX = Math.abs(X - _aMan.finishCell.X);

    if (distX > distY) {
      hCost = 14*distY + 10*(distX-distY);
    } else {
      hCost = 14*distY + 10*(distY-distX);
    }
    fCost = hCost+gCost;
  }

  void drawCell() {
    strokeWeight(3);
    fill(c);
    rect(X*parent.cellW, Y*parent.cellH, parent.cellW, parent.cellH);

    if ((type == 4 || type == 5) && (parent.cellW > 50 && parent.cellH > 50)) {
      fill(0);
      textSize(11);
      textAlign(LEFT);
      text(str(gCost), X*parent.cellW+5, Y*parent.cellH+15);
      textAlign(RIGHT);
      text(str(hCost), X*parent.cellW + parent.cellW - 5, Y*parent.cellH + 15);
      textAlign(CENTER);
      textSize(20);
      text(str(hCost+gCost), X*parent.cellW+(parent.cellW/2), Y*parent.cellH+(parent.cellH/2)*1.2);
    } else if ((type == 0 || type == 3) && (parent.cellW > 50 && parent.cellH > 50)) {
      fill(255);
      textAlign(CENTER);
      textSize(20);
      String s = "Start";
      if (type == 3) {
        s = "Finish";
      }
      text(s, X*parent.cellW+(parent.cellW/2), Y*parent.cellH+(parent.cellH/2)*1.2);
    }
  }

  protected void update() {
    if ((mouseX>X*parent.cellW && mouseX <X*parent.cellW+parent.cellW) && (mouseY>Y*parent.cellH && mouseY<Y*parent.cellH+parent.cellH)) {
      c = color(150);
      isHovered = true;
    } else {
      isHovered = false;
      switch(type) {
        case(0):
        case(3):
        c = color(0, 150, 255);  
        break;
        case(1):
        c = color(255);
        break;
        case(2):
        c = color(0);
        break;
        case(4):
        c = color(0, 255, 0);
        break;
        case(5):
        c = color(255, 0, 0);
        break;
        case(6):
        c = color(255, 0, 255);
        break;
      }
    }

    drawCell();
  }

  protected void paint(int newType) {
    if (mouseButton == RIGHT) {
      type = 1;
      _aMan.checkCellState(this);
    } else {
      type = newType;
    }
  }
}

//----------------------------------A* Shit
class AstarManager {
  gridCell startCell, finishCell;
  grid pathGrid;

  ArrayList<gridCell> open = new ArrayList<gridCell>();
  ArrayList<gridCell> closed = new ArrayList<gridCell>();
  ArrayList<gridCell> way = new ArrayList<gridCell>();

  gridCell shortest = null;

  public void startPathFinder() {
    if (shortest == null) {
      pathFind(startCell);
    } else {
      pathFind(shortest);
    }
  }

  void pathFind(gridCell newCell) {
    if (newCell != startCell) {
      newCell.paint(5);
      open.remove(newCell);
      closed.add(newCell);
      shortest = null;
    }

    for (int y = newCell.Y-1; y < newCell.Y+2; y++) {
      for (int x = newCell.X-1; x < newCell.X+2; x++) {
        if ((x >= 0 && y >= 0) && (x < _grid.gridW && y < _grid.gridH)) {
          gridCell c = pathGrid.get(x, y);
          if (c.type == 1) {
            c.calculateCost(newCell);
            c.paint(4);
            open.add(c);

            if (shortest == null) {
              shortest = c;
            }
            if (c.fCost < shortest.fCost) {
              shortest = c;
            }
          }
          if (c.type==3) {

            //WEG MAKIEREN

            // for(gridCell c1 : closed){
            //  c1.paint(6); 
            //}
            finished = "Found the Way";
            fin = true;
            start = false;
            return;
          }
        }
      }
    }
    for (gridCell c : open) {
      if (shortest == null) {
        shortest = c;
      }
      if (c.fCost < shortest.fCost) {
        shortest = c;
      }
    }
    if (open.size() == 0 && start) {
      finished = "Couldn't find the way";
      fin = true;
      start = false;
      return;
    }
  }

  public AstarManager(grid _g) {
    pathGrid = _g;
  }

  public void setStart(gridCell cell) {
    if (startCell != null) {
      startCell.paint(1);
    }
    startCell = cell;
    cell.paint(0);
  }

  public void setFinish(gridCell cell) {
    if (finishCell != null) {
      finishCell.paint(1);
    }
    finishCell = cell;
    cell.paint(3);
  }

  public void checkCellState(gridCell newCell) {
    if (startCell == newCell) {
      startCell = null;
    }

    if (finishCell == newCell) {
      finishCell = null;
    }
  }
}
