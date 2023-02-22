import de.bezier.guido.*;
public final static int NUM_ROWS = 20; // constants
public final static int NUM_COLS = 20;
public final static int NUM_MINES = 50;
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines = new ArrayList<MSButton>(); //ArrayList of just the minesweeper buttons that are mined
public boolean gameLost = false;
public boolean gameDone = false;
public boolean isFirstClick = true;

void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    initGame();
}
public void initGame() {
  // initialize buttons
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for (int i = 0; i < NUM_ROWS; i++) {
      for (int j = 0; j < NUM_COLS; j++) {
        buttons[i][j] = new MSButton(i, j);
      }
    }
    setMines();
}

public void setMines()
{
    mines = new ArrayList<MSButton>();
    for (int i = 0; i < NUM_MINES; i++) {
      int r = (int)(Math.random() * NUM_ROWS);
      int c = (int)(Math.random() * NUM_COLS);
      if ( !(mines.contains(buttons[r][c])) ) {
        mines.add(buttons[r][c]);
      } else { 
        i--;
      }
    }
}

public void draw ()
{
    background( 0 );
    if(isWon()) {
        displayWinningMessage();
    }
    else if (gameLost) {
        displayLosingMessage();
    }
}
public boolean isWon()
{
    for (int i = 0; i < NUM_ROWS; i++) {
      for (int j = 0; j < NUM_COLS; j++) {
        if (!mines.contains(buttons[i][j]) && !buttons[i][j].isClicked())
          return false; // if it is NOT a mine and it is NOT clicked, game is not yet won
        if (mines.contains(buttons[i][j]) && !buttons[i][j].isFlagged()) 
          return false; // if it IS a mine and it is NOT flagged, game is not yet won
      }
    }
    return true; // else, game must have been won
}
public void displayLosingMessage()
{
    displayCenterMessage("YOU LOSE");
    for (int i = 0; i < mines.size(); i++) {
      mines.get(i).mousePressed();
    }
    gameDone = true;
}
public void displayWinningMessage()
{
    displayCenterMessage("YOU WIN!");
    gameDone = true;
}
public void displayCenterMessage(String msg) {
  for (int i = 0; i < msg.length(); i++) {
    int curCol = NUM_COLS/2 - msg.length()/2 + i;
    if (curCol >= 0 && curCol < NUM_COLS) 
      buttons[NUM_ROWS/2][curCol].setLabel(msg.substring(i, i+1));
    }
}

public boolean isValid(int r, int c)
{
    return (r >= 0 && r < NUM_ROWS) && (c >= 0 && c < NUM_COLS);
}
public int countMines(int row, int col)
{
    int numMines = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (isValid(row+i,col+j) && mines.contains(buttons[row+i][col+j])) numMines++;
      }
    }
    return numMines;
}
public class MSButton
{
    private int myRow, myCol;
    private float x,y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton ( int row, int col )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        myRow = row;
        myCol = col; 
        x = myCol*width;
        y = myRow*height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add( this ); // register it with the manager
    }

    // called by manager
    public void mousePressed () 
    {
        if (gameDone) return;
        clicked = true;
        if (isFirstClick) {
          isFirstClick = false;
          while (mines.contains(this)) {
            setMines();
          }
        }
        if (mouseButton == RIGHT) {
          flagged = !flagged;
          if (!flagged) clicked = false;
        } else if (mines.contains(this)) {
          gameLost = true;
        } else if (countMines(myRow, myCol) > 0) {
          setLabel(countMines(myRow, myCol));
        } else {
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (isValid(myRow+i, myCol+j) && !(buttons[myRow+i][myCol+j].isClicked())) {
                buttons[myRow+i][myCol+j].mousePressed();
              }
            }
          }
        }
    }
    public void draw () 
    {    
        if (flagged)
            fill(255, 150, 150, 128);
         else if( clicked && mines.contains(this) ) 
             fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );

        rect(x, y, width, height);
        fill(0);
        textSize(14);
        text(myLabel,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    public void setLabel(int newLabel)
    {
        myLabel = ""+ newLabel;
    }
    public boolean isFlagged()
    {
        return flagged;
    }
    public boolean isClicked() {
        return clicked;
    }
}
