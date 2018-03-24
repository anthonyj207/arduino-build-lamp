// Build Status Lamp

#define RED_LED_ONE 2
#define RED_LED_TWO 3
#define YELLOW_LED 4
#define GREEN_LED 5

#define GLOWING 1
#define FADING 0

#define BUILD_UNDEFINED 0
#define BUILD_FAILED 1
#define BUILD_BUILDING 2
#define BUILD_SUCCESS 3

int _queryWaitCounter = 0;

int _fadeCounter = 0;
int _fadeStatus = GLOWING;

int _buildStatus = BUILD_UNDEFINED;
int _oldBuildStatus = BUILD_UNDEFINED;

void setup()
{
  randomSeed(analogRead(5));
        
  Serial.begin(9600);
  
  pinMode(RED_LED_ONE, OUTPUT);
  pinMode(RED_LED_TWO, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);    // Hardware PWM
}

void loop()
{
  _buildStatus = GetBuildStatus(_buildStatus);
  
  switch(_buildStatus)
  {
    case BUILD_UNDEFINED:
    {
      if (_oldBuildStatus == BUILD_SUCCESS)
      {
        ResetGlowUpdateLED(GREEN_LED);
      }
      
      _oldBuildStatus = _buildStatus;
            
      long rand = random(50, 500);
      long randomLED = random(2, 6);
      FlashLED(randomLED, rand);
      
      break;
    }
    case BUILD_FAILED:
    {
      if (_oldBuildStatus == BUILD_SUCCESS)
      {
        ResetGlowUpdateLED(GREEN_LED);
      }
      
      _oldBuildStatus = _buildStatus;
      
      AlternateFlashLED(RED_LED_ONE, RED_LED_TWO, 100);
      
      break;
    }
    case BUILD_BUILDING:
    {
      if (_oldBuildStatus == BUILD_SUCCESS)
      {
        ResetGlowUpdateLED(GREEN_LED);
      }

      _oldBuildStatus = _buildStatus;
      
      FlashLED(YELLOW_LED, 500);
      
      break; 
    }
    case BUILD_SUCCESS:
    {
      _oldBuildStatus = _buildStatus;
      
      GlowUpdateLED(GREEN_LED);
      
      break;
    }
  }
  
  delay(100);
}

int hex2dec(byte c)
{
  // converts one HEX char into a number
  if (c >= '0' && c <= '9')
  {
    return c - '0';
  }
  else if (c >= 'A' && c <= 'F')
  {
    return c - 'A' + 10;
  }
}

int GetBuildStatus(int currentBuildStatus)
{
  char buffer[2];
  int pointer = 0;
  byte inByte = 0;
  int buildStatus = BUILD_UNDEFINED;

  if (Serial.available() > 0)
  {
    inByte = Serial.read();
    
    if (inByte == '#')
    {
      while (pointer < 1)
      {
        buffer[pointer] = Serial.read();
        pointer++;
      }
      
      buildStatus = hex2dec(buffer[0]);
    }
  } 
  
  if (buildStatus == BUILD_UNDEFINED)
    buildStatus = currentBuildStatus;
    
  return buildStatus;
}

void TurnOnLED(int LEDId)
{
   digitalWrite(LEDId, HIGH);  
}

void TurnOffLED(int LEDId)
{
   digitalWrite(LEDId, LOW);
}

void FlashLED(int LEDId, int waitDelay)
{
  delay(waitDelay);
  TurnOnLED(LEDId);
  delay(waitDelay);
  TurnOffLED(LEDId);
}

void BlinkLED(int LEDId, int period)
{
   TurnOnLED(LEDId);
   delay(period);
   TurnOffLED(LEDId);
}

void AlternateFlashLED(int LEDIdOne, int LEDIdTwo, int period)
{
  BlinkLED(LEDIdOne, period);
  delay(period);
  BlinkLED(LEDIdOne, period);
  delay(period);
  BlinkLED(LEDIdTwo, period);
  delay(period);
  BlinkLED(LEDIdTwo, period);
}

void ResetGlowUpdateLED(int LEDId)
{
  TurnOffLED(LEDId);
  
  _fadeCounter = 0;
  _fadeStatus = GLOWING;
}

void GlowUpdateLED(int LEDId)
{
  if (_fadeStatus == GLOWING)
  {
    //_fadeCounter++;
    _fadeCounter += 4;
    
    if (_fadeCounter > 255)
    {
      _fadeCounter = 255;
      _fadeStatus = FADING;
    }    
  }
  else
  {
    //_fadeCounter--;
    _fadeCounter -= 4;
    
    if (_fadeCounter < 0)
    {
      _fadeCounter = 0;
      _fadeStatus = GLOWING;
    }
  }
  
  analogWrite(LEDId, _fadeCounter);
  delay(10);
}