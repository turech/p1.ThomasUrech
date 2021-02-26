import controlP5.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

final int FRAME_RATE = 30;
final int NULL_PRESS = -7;
final int HANDLE_VAL = -6;
final int START_VAL = -5;
final int STOP_VAL = -4;
final int CLOCK_VAL = -3;
final int TIMER_VAL = -2;
final int POWER_VAL = -1;

final int DISP_CLOCK = 0;
final int SET_CLOCK = 1;
final int SET_TIMER = 2;
final int RUN_TIMER = 3;
final int PAUSE_TIMER = 4;
final int SET_COOK = 5;
final int RUN_COOK = 6;
final int PAUSE_COOK = 7;
final int END_COOK = 8;

final int MAX_POW = 4;

ControlP5 cp5;
Minim minim;
AudioOutput out;

Clock clock;
Timer timer;
Setter setter;
int state;
int next_button;
int power;
boolean light_on;
boolean door_open;
int unmutelag = 0;
/**
* Sets up the microwave
* Sets all global variable to their default value
*  NOTE: clock is set to framerate of 1 so that we can see it move.
*  It will tick up once every two seconds
* Initializes 16 buttons
* Power controls the mmicrowave's power output
* Timer lets the user set a non-cook timer
* Clock lets the user set the microwave's clock
* Number 0-9 let the user input numbers into the microwave
* Start begins timers, cooking, and confirms the clock
* Stop ends timers, cooking, and exits out of set modes
* The handle opens and closes the door. Cannot cook with the door open
*  So if the microwave is cooking and the door opens, it pauses cooking
*/
void setup()
{
  size(1600,950);
  frameRate(FRAME_RATE);
  cp5  = new ControlP5(this);
  
  minim = new Minim(this);
  out = minim.getLineOut();
  out.pauseNotes();
  PFont font = loadFont("ArialMT-24.vlw");
  cp5.setFont(font);
  cp5.addButton("Power").setPosition(1200,200).setSize(95,95).setValue(POWER_VAL);
  cp5.addButton("Timer").setPosition(1300,200).setSize(95,95).setValue(TIMER_VAL);
  cp5.addButton("Clock").setPosition(1400,200).setSize(95,95).setValue(CLOCK_VAL);
  
  cp5.addButton("One").setPosition(1200,350).setSize(95,95).setValue(1).setCaptionLabel("1");
  cp5.addButton("Two").setPosition(1300,350).setSize(95,95).setValue(2).setCaptionLabel("2");
  cp5.addButton("Three").setPosition(1400,350).setSize(95,95).setValue(3).setCaptionLabel("3");
  cp5.addButton("Four").setPosition(1200,450).setSize(95,95).setValue(4).setCaptionLabel("4");
  cp5.addButton("Five").setPosition(1300,450).setSize(95,95).setValue(5).setCaptionLabel("5");
  cp5.addButton("Six").setPosition(1400,450).setSize(95,95).setValue(6).setCaptionLabel("6");
  cp5.addButton("Seven").setPosition(1200,550).setSize(95,95).setValue(7).setCaptionLabel("7");
  cp5.addButton("Eight").setPosition(1300,550).setSize(95,95).setValue(8).setCaptionLabel("8");
  cp5.addButton("Nine").setPosition(1400,550).setSize(95,95).setValue(9).setCaptionLabel("9");
  cp5.addButton("Zero").setPosition(1300,650).setSize(95,95).setValue(0).setCaptionLabel("0");
  
  cp5.addButton("Stop").setPosition(1200,800).setSize(95,95).setValue(STOP_VAL);
  cp5.addButton("Start").setPosition(1400,800).setSize(95,95).setValue(START_VAL);
  cp5.addButton("Handle").setPosition(900,80).setSize(125,800).setValue(HANDLE_VAL);
  
  
  clock = new Clock(FRAME_RATE);
  timer = new Timer();
  setter = new Setter();
  state = DISP_CLOCK;
  next_button = NULL_PRESS;
  power = MAX_POW;
  light_on = false;
  door_open = false;
  out.mute();
  out.resumeNotes();
}


/**
* Runs the mircowave every frame
* 1) tick the clock
* 2) set the background color to dark grey
* 3) run the current state (move timers forward)
*      If a timer finishes, the state updates here
* 4) take user input to update the state, set timers
* 5) use the new state to set the clock display
* 6) show the clock display on the microwave
* 7) draw the door and window on the microwave
* 8) draw the rest of the display on the microwave
*      Including the power level and the state of the clock
*/
void draw()
{
  clock.tick();
  background(30);
  if(unmutelag > frameRate)
  {
    out.unmute();
  }
  state = runState(state);
  state = takeInput(next_button, state);
  int[] time = get_display(state);
  String clock = display(time);
  if(state == RUN_COOK || door_open)
  {
    light_on = true;
  }
  else
  {
    light_on = false;
  }
  //window
  if(light_on)
    fill(251,255,139);
  else
    fill(0);
  rect(25,25,1050,900,30);
  window_hash(25,25,1050,900);
  //handle
  fill(30);
  rect(875,50,175,850,30);
  //door line
  stroke(255);
  line(1100,0,1100,950);
  stroke(30);
  //clock display
  fill(255);
  rect(1150,25,400,145,7);
  //clock
  fill(0);
  textSize(108);
  text(clock,1225,125);
  //clock state
  textSize(24);
  if(state >= 5)
    text("Cook",1250,160);
  else if(state > 1 && state < 5)
    text("Timer",1350,160);
  else
    text("Clock",1450,160);
  //power bar
  power_bar(power);
  unmutelag++;
}

void window_hash(int Wx, int Wy, int Ww, int Wh)
{
  for(int i = 0; i <= Wh; i += 25)
  {
    line(Wx+i,Wy,Wx,Wy+i);
    line(Wx+Ww,Wy+i,Wx+Ww-i,Wy);
  }
  for(int i = 25; i <= Ww - Wh; i += 25)
  {
    line(Wx + i,Wy + Wh,Wx + Wh + i,Wy);
    line(Wx+Ww-i,Wy+Wh,Wx + (Ww - Wh) - i,Wy);
  }
  for(int i = 25; i <=Wh; i+= 25)
  {
    line(Wx + Ww-Wh + i, Wy + Wh, Wx + Ww, Wy + i);
    line(Wx,Wy+i,Wx + Wh - i,Wy+Wh);
  }
}

void power_bar(int pow)
{
  fill(0,255,0);
  for(int i = 0; i <= pow; i++)
  {
    rect(1160,132 - 24*i,50,20,1);
  }
}
/**
* Performs state operations that do not reqire input
* Run timer and run cook: updates the timer every frame
* Run cook: low noise to indicate cooking
* When both are finished, they chime to indicate they are done
* and transfer to their finished states
* Most states have no passive updates
* @param s the current state
* @return the next state
*/
int runState(int s)
{
  int ret = s;
  switch(s)
  {
    case DISP_CLOCK:
      break;
    case SET_CLOCK:
      break;
    case SET_TIMER:
      break;
    case RUN_TIMER:
      timer.update();
      if(timer.remaining() == 0)
      {
        ret = DISP_CLOCK;
        out.playNote(0,0.5,1108.73); //Db6
        out.playNote(1,0.5,1108.73);
        out.playNote(2,0.5,1108.73);
        out.playNote(3,0.5,1108.73);
      }
      break;
    case PAUSE_TIMER:
      break;
    case SET_COOK:
      break;
    case RUN_COOK:
      timer.update();
      if(timer.remaining() == 0)
      {
        ret = END_COOK;
        out.playNote(0,0.5,1174.66); //D6
        out.playNote(1,0.5,1174.66);
        out.playNote(2,0.5,1174.66);
        out.playNote(3,0.5,1174.66);
      }
      else
      {
         out.playNote(0,0.5,49.00);//C1
      }
      break;
    case PAUSE_COOK:
      break;
    case END_COOK:
      break;
    default: //disp 12:00
  }
  return ret;
}
/**
* Takes the user input and current machine state to make a new machine state
* Also sets timer
* @param b the most recent button pressed
* @param s the current machine state
* @return the next state
*/
int takeInput(int b, int s)
{
  int new_state = s;
  switch(s)
  {
    case DISP_CLOCK:
      new_state = disp_clock(b);
      break;
    case SET_CLOCK:
      new_state = set_clock(b);
      break;
    case SET_TIMER: 
      new_state = set_timer(b);
      break;
    case RUN_TIMER:
      new_state = run_timer(b);
      break;
    case PAUSE_TIMER:
      new_state = pause_timer(b);
      break;
    case SET_COOK:
      new_state = set_cook(b);
      break;
    case RUN_COOK:
      new_state = run_cook(b);
      break;
    case PAUSE_COOK:
      new_state = pause_cook(b);
      break;
    case END_COOK:
      new_state = end_cook(b);
      break;
    default: //disp 12:00
  }
  next_button = NULL_PRESS;
  return new_state;
}
/**
* Decides which numbers to return for the clock display based on the state
* Display clock: the clock
* Set clock, set timer, set cool: the setting display
* Run timer, pasue timer: the timer
* Run cook, pasue cook: the timer
* End cook: DONE (-1 in first slot)
* @param the current state
* @return what the microwave should display
*/
int[] get_display(int s)
{
  int[] ret = {1,2,0,0};
  switch(s)
  {
    case DISP_CLOCK:
      return clock.getTime();
    case SET_CLOCK:
      return setter.getTime();
    case SET_TIMER:
      return setter.getTime();
    case RUN_TIMER:
      return timer.getTime();
    case PAUSE_TIMER:
      return timer.getTime();
    case SET_COOK:
      return setter.getTime();
    case RUN_COOK:
      return timer.getTime();
    case PAUSE_COOK:
      return timer.getTime();
    case END_COOK:
      ret[0] = -1;
      return ret;
    default: //disp 12:00
      return ret;
  }
}
/**
* Converts display numbers into text for the display
* @param the numbers to display
* @Return the string representing the numbers to display
*/
String display(int[] time)
{
  if(time[0] == -1)
  {
    return "DONE";
  }
  return str(time[0]) + str(time[1]) + ":" + str(time[2]) + str(time[3]);
  
}
/**
* Display clock state
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "clock", go to set clock state
* If the user presses "timer", go to set timer state
* If the user presses a number, go to set cook state and input the pressed button
* Otherwise (start/stop) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int disp_clock(int b)
{
  int s = DISP_CLOCK;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == CLOCK_VAL)
  {
    s = SET_CLOCK;
  }
  else if(b == TIMER_VAL)
  {
    s = SET_TIMER;
  }
  else if(b >= 0) //press number
  {
    s = SET_COOK;
    setter.input(b);
  }
  else if(b == START_VAL)
  {
    s = RUN_COOK;
    int[] put = {0,0,3,0};
    timer.set(put);
    timer.start(FRAME_RATE);
  }
  return s;
}
/**
* Set the clock
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "clock", restart the clock setting process
* If the user presses "start", update the clock to the setter's time and return to the display clock state
* If the user presses "stop", return to the display clock state without updating the clock
* If the use presses a number, then update the setter with that number
* Otherwise (timer) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int set_clock(int b)
{
  int s = SET_CLOCK;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == CLOCK_VAL)
  {
    setter.reset();
  }
  else if(b == STOP_VAL)
  {
    setter.reset();
    s = DISP_CLOCK;
  }
  else if(b == START_VAL)
  {
    int[] new_clock = setter.getTime();
    clock.set(new_clock);
    setter.reset();
    s = DISP_CLOCK;
  }
  else if(b >= 0) //press number
  {
    setter.input(b);
  }
  return s;
  
}
/**
* Set a timer
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "timer", restart the timer setting process
* If the user presses "start", set setter to timer and go to run timer state
* If the user presses "stop", return to display clock state
* If the user presses a number, update the setter with that number
* Otherwise (clock) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int set_timer(int b)
{
  int s = SET_TIMER;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == TIMER_VAL)
  {
     setter.reset();
  }
  else if(b == START_VAL)
  {
    int[] new_timer = setter.getTime();
    timer.set(new_timer);
    timer.start(FRAME_RATE);
    setter.reset();
    s = RUN_TIMER;
  }
  else if(b == STOP_VAL)
  {
    setter.reset();
    s = DISP_CLOCK;
  }
  else if(b >= 0) //press number
  {
    setter.input(b);
  }
  return s;
}
/**
* Run the timer
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "timer", go to pause timer state
* If the user presses "stop", go to the display clock state
* Otherwise (start/clock/number) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int run_timer(int b)
{
  int s = RUN_TIMER;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == TIMER_VAL)
  {
    s = PAUSE_TIMER;
  }
  else if(b == STOP_VAL)
  {
    s = DISP_CLOCK;
  }
  return s;
}
/**
* Pause timer state
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "timer", go to set timer state
* If the user presses "start", go to run timer state
* If the user presses "stop", go to display clock state
* Otherwise (clock/numer) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int pause_timer(int b)
{
  int s = PAUSE_TIMER;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == TIMER_VAL)
  {
    s = SET_TIMER;
  }
  else if(b == START_VAL)
  {
    s = RUN_TIMER;
  }
  else if(b == STOP_VAL)
  {
    s = DISP_CLOCK;
  }
  return s;
}
/**
* Set cook state
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "start", set setter to timer and go to run cook state
*   ONLY IF door is closed. If door is not closed, do nothing
* If the user presses "stop", go to display clock state
* If the user presses a number, update the setter with that number
* Otherwise (timer/clock) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int set_cook(int b)
{
  int s = SET_COOK;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == START_VAL && !door_open)
  {
    int[] new_timer = setter.getTime();
    timer.set(new_timer);
    timer.start(FRAME_RATE);
    setter.reset();
    s = RUN_COOK;
  }
  else if(b == STOP_VAL)
  {
    setter.reset();
    s = DISP_CLOCK;
  }
  else if(b >= 0)//press number
  {
    setter.input(b);
  }
  return s;
}
/**
* Run cook state
* If the user presses "handle", go to pause cook state
* If the user presses "stop", go to display clock state
* Otherwise (power/timer/clock/number) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int run_cook(int b)
{
  int s = RUN_COOK;
  if(b == HANDLE_VAL)
  {
    s = PAUSE_COOK;
    door_open = !door_open;
  }
  else if(b == STOP_VAL)
  {
    s = DISP_CLOCK;
  }
  return s;
}
/**
* Display clock state
* If the user presses "power", adjust the power level
* If the user presses "handle", open or close the door
* If the user presses "start", go to set run cook state
  ONLY IF door is closed. Otherwise do nothing
* If the user presses "stop", go to display clock state
* Otherwise (timer/clock) do nothing
* @param the value of the button pressed
* @return the next state
*/
public int pause_cook(int b)
{
  int s = 7;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == START_VAL && !door_open)
  {
    s = RUN_COOK;
  }
  else if(b == STOP_VAL)
  {
    s = DISP_CLOCK;
  }
  return s;
}
/**
* Display clock state
* If the user presses "power", adjust the power level and go to display clock state
* If the user presses "handle", open the door and go to display clock state
* If the use does nothing, do nothing
* Otherwise (timer/clock/number/start/stop) go to the display clock state
* @param the value of the button pressed
* @return the next state
*/
public int end_cook(int b)
{
  int s = DISP_CLOCK;
  if(b == POWER_VAL)
  {
    update_power();
  }
  else if(b == HANDLE_VAL)
  {
    door_open = !door_open;
  }
  else if(b == NULL_PRESS)
  {
    s = END_COOK;
  }
  return s;
}
/**
* Updates the power level
* Increases power level by one, if at 5, reduces it to 1
*/
public void update_power()
{
  power = ((power + 1) % (MAX_POW + 1));
  switch(power)
  {
    case 0:
      out.playNote(0,0.5,220.00);//A3
      break;
    case 1:
      out.playNote(0,0.5,233.08);//A#3
      break;
    case 2:
      out.playNote(0,0.5,246.94);//B3
      break;
    case 3:
      out.playNote(0,0.5,261.63);//C4
      break;
    default:
      out.playNote(0,0.5,277.18);//C#4
      
  }
}
/**
* Pressing a button saves the input of that button until the 
* Next call of draw. Once draw is called, it runs the machine
* Based on the current state and the button pressed.
* After the button press is handled, the input is reset.
*/
public void One(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,523.25);//C5
  println(theValue);
}
public void Two(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,554.37);//C#5
  println(theValue);
}
public void Three(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,622.25);//E5
  println(theValue);
}
public void Four(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,659.25);//Eb5
  println(theValue);
}
public void Five(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,698.46);//F5
  println(theValue);
}
public void Six(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,783.99);//G5
  println(theValue);
}
public void Seven(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,880.00);//A5
  println(theValue);
}
public void Eight(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,932.33);//Bb5
  println(theValue);
}
public void Nine(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,987.77);//B5
  println(theValue);
}
public void Zero(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,1046.50);//C6
  println(theValue);
}
public void Power(int theValue){
  next_button = theValue;
  println("Power");
}
public void Timer(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,349.23);//F4
  println("Timer");
}
public void Clock(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,392.00);//G4
  println("Clock");
}
public void Stop(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,440.00);//A4
  out.playNote(0,0.5,622.25);//E#5
  println("Stop");
}
public void Start(int theValue){
  next_button = theValue;
  out.playNote(0,0.5,493.88);//B4
  out.playNote(0,0.5,739.99);//F#5
  println("Start");
}
public void Handle(int theValue){
  next_button = theValue;
  if(!door_open)
  {
    out.playNote(0,0.25,123.47);//B2
    out.playNote(0.25,.25,155.56);//D#3
  }
  else
  {
    out.playNote(0.25,0.25,123.47);//B2
    out.playNote(0,0.25,155.56);//D#3
  }
  println("Handle");
}
