class Setter
{
  int a1;
  int a2;
  int a3;
  int a4;
  public Setter()
  {
    a1 = 0;
    a2 = 0;
    a3 = 0;
    a4 = 0;
  }
  
  public int[] input(int next)
  {
    a1 = a2;
    a2 = a3;
    a3 = a4;
    a4 = next;
    int[] ret = {a1,a2,a3,a4};
    return ret;
  }
  
  public int[] set(int[] update)
  {
    int[] ret = {a1,a2,a3,a4};
    a1 = update[0];
    a2 = update[1];
    a3 = update[2];
    a4 = update[3];
    return ret;
  }
  
  public int[] reset()
  {
    int[] ret = {a1,a2,a3,a4};
    a1 = 0;
    a2 = 0;
    a3 = 0;
    a4 = 0;
    return ret;
  }
  
  public int[] getTime()
  {
    int[] ret = {a1,a2,a3,a4};
    return ret;
  }
}
