import de.bezier.guido.*;
public final static int NUM_ROWS = 20; // constants
public final static int NUM_COLS = 20;
public final static int NUM_MINES = 50;
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines = new ArrayList<MSButton>(); //ArrayList of just the minesweeper buttons that are mined
public boolean gameDone = false; // this boolean is used to stop clicks after the game is over
public boolean isFirstClick = true; // this boolean is used for "safe first click" (i.e first click is never a mine)

void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    initGame();
}

public void draw ()
{
    background( 0 );
    if(isWon()) {
        displayWinningMessage();
    }
    else if (gameDone) {
        displayLosingMessage();
    }
}

/* GAME RELATED FUNCTIONS */

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
      } else { // make sure that even if we get duplicates, the total number of mines is still NUM_MINES 
        i--;
      }
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
      mines.get(i).setClicked(true);
      mines.get(i).setFlagged(false);
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

/* BUTTON AND MINE RELATED FUNCTIONS */

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
        if (isFirstClick) { // first click is always a "0" (blank) square
          isFirstClick = false;
          while (mines.contains(this) || countMines(myRow, myCol) > 0) {
            setMines();
          }
        }
        if (mouseButton == RIGHT) { //  handle flagging
          flagged = !flagged;
          if (!flagged) clicked = false;
        } else if (flagged) { // prevent accidental clicking of flagged buttons
          return;
        }else if (mines.contains(this)) { // end the game if you click a mine
          displayLosingMessage();
        } else if (countMines(myRow, myCol) > 0) { // show number of neighboring mines
          setLabel(countMines(myRow, myCol));
        } else { // recurse through valid neighbors
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
      // color of square
        if (flagged)
            fill(255, 150, 150, 128);
        else if( clicked && mines.contains(this) ) 
             fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );
        rect(x, y, width, height);
        
      // color of text
        if (myLabel.equals("1")) fill(0, 0, 255);
        else if (myLabel.equals("2")) fill(0, 255, 0);
        else if (myLabel.equals("3")) fill(255, 0, 0); // TODO HERE <----------------------------
        else fill(0);
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
    public void setClicked(boolean val) {
      clicked = val;
    }
    public void setFlagged(boolean val) {
      flagged = val;
    }
}
