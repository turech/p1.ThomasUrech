
class Clock
{
  int h1;
  int h2;
  int m1;
  int m2;
  int tick;
  int second;
  
  public Clock(int frameRate)
  {
    int hour = hour();
    h1 = (int) floor(hour / 10);
    h2 = hour % 10;
    int minute = minute();
    m1 = (int) floor(minute / 10);
    m2 = minute % 10;
    second = frameRate;
    tick = 1;
  }
  
  public int[] set(int[] update)
  {
    int[] ret = getTime();
    h1 = update[0]%3;
    if(h1 == 2)
      h2 = update[1]%5;
    else
      h2 = update[1]%10;
    m1 = update[2]%6;
    m2 = update[3]%10;
    return ret;
  }
  
  public void tick()
  {
    if(tick == 60*second)
    {
      tick = 0;
      m2++;
      if(m2 > 9)
      { 
        m2 = 0;
        m1++;
        if(m1 > 5)
        {
          m1 = 0;
          h2++;
          if(h2 > 9 && h1 < 2)
          {
            h2 = 0;
            h1++;
          }
          else if(h2 > 3 && h1 >= 2)
          {
            h2 = 0;
            h1 = 0;
          }
        }
      }  
    }
    tick++;
  }
  
  public int[] getTime()
  {
    int[] ret = {h1,h2,m1,m2};
    return ret;
  }
}
