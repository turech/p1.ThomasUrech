class braille
{
  boolean[] members;
  int xPos;
  int yPos;
  int size;
  braille(char symbol,int x, int y, int s)
  {
    members = alphabet(symbol);
    xPos = x;
    yPos = y;
    size = s;
  }
  
  void draw()
  {
    int dia = size / 5;
    int xLoc = xPos + dia;
    int yLoc = yPos + dia;
    if(members[0])
    {ellipse(xLoc,yLoc,dia,dia);}
    yLoc += 2*dia;
    if(members[1])
    {ellipse(xLoc,yLoc,dia,dia);}
    yLoc += 2*dia;
    if(members[2])
    {ellipse(xLoc,yLoc,dia,dia);}
    yLoc = yPos + dia;
    xLoc += 2*dia;
    if(members[3])
    {ellipse(xLoc,yLoc,dia,dia);}
    yLoc += 2*dia;
    if(members[4])
    {ellipse(xLoc,yLoc,dia,dia);}
    yLoc += 2*dia;
    if(members[5])
    {ellipse(xLoc,yLoc,dia,dia);}
  }
  
  /**
  1  4
  2  5
  3  6
  */
  boolean[] alphabet(char letter)
  {
    switch(letter)
    {
    case 'a': return set(1);
    case 'b': return set(12);
    case 'c': return set(14);
    case 'd': return set(145);
    case 'e': return set(15);
    case 'f': return set(124);
    case 'g': return set(1245);
    case 'h': return set(145);
    case 'i': return set(24);
    case 'j': return set(245);
    case 'k': return set(13);
    case 'l': return set(123);
    case 'm': return set(124);
    case 'n': return set(1345);
    case 'o': return set(135);
    case 'p': return set(1234);
    case 'q': return set(12345);
    case 'r': return set(1235);
    case 's': return set(234);
    case 't': return set(2334);
    case 'u': return set(136);
    case 'v': return set(1236);
    case 'w': return set(2456);
    case 'x': return set(1346);
    case 'y': return set(13456);
    case 'z': return set(1356);
    case '#': return set(3456);
    case '1': return set(1);
    case '2': return set(12);
    case '3': return set(14);
    case '4': return set(145);
    case '5': return set(15);
    case '6': return set(124);
    case '7': return set(1245);
    case '8': return set(125);
    case '9': return set(24);
    case '0': return set(245);
    default: return set(0);
    }
  }
  
  boolean[] set(int s)
  {
    boolean[] ret = {false, false, false, false, false, false};
    boolean goOn = true;
    while(goOn)
    {
      int next = s % 10;
      ret[next - 1] = true;
      if(s > 10)
      {
        s = (int) s / 10;
      }
      else
      {
        goOn = false;
      }
    }
    return ret;
  }
}
