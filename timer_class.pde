class Timer
{
  int[] clock = {0,0,0,0};
  int ctime;
  int interval;
  public Timer(int[] set_time)
  {
    clock[0] = set_time[0] % 10;
    clock[1] = set_time[1] % 10;
    clock[2] = set_time[2] % 10;
    clock[3] = set_time[3] % 10;
  }
  
  public Timer()
  {
    clock[0] = 0;
    clock[1] = 0;
    clock[2] = 0;
    clock[3] = 0;
  }
  
  public void set(int[] set_time)
  { 
    clock[0] = set_time[0] % 10;
    clock[1] = set_time[1] % 10;
    clock[2] = set_time[2] % 10;
    clock[3] = set_time[3] % 10;
  }
  
  public void start(int frameRate)
  {
    ctime = 0;
    interval = frameRate;
  }
  
  public void update()
  {
    if(remaining() > 0)
    {
      if(interval - ctime == 0)
      {
        clock = count_down();
        ctime = 0;
      }
      ctime++;
    }
  }
  
  public int[] getTime()
  {
    return clock;
  }
  
  public int remaining()
  {
    return clock[0]*600 + clock[1]*60 + clock[2]*10 + clock[3];
  }
  
  private int[] count_down()
  {
    int[] temp = clock;
    temp[3]--;
    if(temp[3] < 0)
    {
      temp[3] = 9;
      temp[2]--;
      if(temp[2] < 0)
      {
        temp[2] = 5;
        temp[1]--;
        if(temp[1] < 0)
        {
          temp[1] = 9;
          temp[0]--;
          if(temp[0] < 0)
          {
            temp[0] = 0;
          }
        }
      }
    }
    return temp;
  }
}
