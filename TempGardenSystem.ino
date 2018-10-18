// Libraries Included
#include <SoftwareSerial.h>       // Allows serial communication on 0 and 1 digital pins of the Arduino
#include <dht.h>                  // Library for temperature and humidity sensor
#include <NS_energyShield2.h>     // Library for rechargeable battery
#include <NS_eS2_Utilities.h>     // Library for rechargeable battery
#include <SD.h>                   // Library for writing data onto an SD card


// Defined Solar Panel Maximum Power Point Voltage (VMPP)
#define ASSUMED_VMPP 17500
#define MAX_VMPP 22000
#define MIN_VMPP 12000


// DHT Sensor Definition
dht DHT;              // Initialize the sensor
#define DHT11_PIN 7   // DHT (Humidity&Temp) data pin connected to Arduino's 7th pin


// Water Solenoid Valve Pin Set-up
int waterPin = 6;


//   Soil Moisture Sensor Variables 
int soilSensorPin = A0;
int soilSensorValue = 0;
int soilPercentage = 0;


// Global Rechargeable Battery Object
NS_energyShield2 es2;


//  Measuring Solar Power Variables
unsigned int  VMPP;
long          lastMillis;


//  File Object
File myFile;


//  Pin the SD is Connected to
const int chipSelect = 10;


void setup() 
{
  // Initializes the energyShield 2
  es2.begin();

  // Read and set VMPP
  VMPP = es2.readVMPP();
  if (VMPP == -1) VMPP = ASSUMED_VMPP; // If regulation is disabled (first time) set VMPP to initial guess
 
  es2.batteryAlert(20); // Battery low LED to alert at 20%

  // Initialize the SD
  SD.begin(chipSelect);

  // set pin for water solenoid valve as output
  pinMode(waterPin, OUTPUT);

  delay(10);

  // set pin for SD module
  pinMode(chipSelect, OUTPUT);

  delay(10);
}

void loop() 
{
  writeData();
  maximizeSolarPower();
  es2.sleepSeconds(14400); // Sleep for 4 hours(3600/h)
}

int convertToPercentage(int value)
{
  int percentValue = 0;
  percentValue = map(value,550,0,0,100);
  return percentValue;
}

void waterGarden()
{
  unsigned long seconds = 1000L;              // ms to s
  unsigned long fivemins = seconds * 60 * 5;  // 5 minute conversion

  digitalWrite(waterPin, HIGH);  //Switch Solenoid ON
  delay(fivemins);               //Delay for set amount of time before turning off 
  digitalWrite(waterPin, LOW);   //Switch Solenoid OFF
  delay(1000);                   //Wait 1 Second
}

void maximizeSolarPower(){
/*********************************************
  Method Maximizes Solar Panel Power Output
  Algorithm created by Aaron D. Liebold
  on January 30, 2017
 
  Distributed under the MIT license
  Copyright 2017 NightShade Electronics
  https://opensource.org/licenses/MIT
*********************************************/
  if (es2.batteryCurrent() > 0) {
    unsigned long lastPower, newPower;
    int reverse = 0;
 
    // Calculated current power to battery // P = V * I
    lastPower = (unsigned long) es2.batteryVoltage() * es2.batteryCurrent();
 
    do {
      es2.setVMPP(VMPP, 0); // Set voltage regulation to new value, but do not write EEPROM (EEPROM has an expected write life of 1,000,000 cycles, don't waste it.)
 
      delay(2000); // Wait for system to settle and fuel gauge to measure new average current (>1 sec)
 
      // Measure and calculate new power
      newPower = (unsigned long) es2.batteryVoltage() * es2.batteryCurrent();
 
      // If power decreased, change direction
      if (newPower < lastPower) ++reverse;
 
      // Perturb voltage setpoint in the current direction of travel
      if (reverse % 2) {
        VMPP += 100;
      }
      else {
        VMPP -= 100;
      }
 
      // Change direction if setpoint get to the edge of the acceptable voltage range (7.0V - 90% Open-circuit Voltage)
      // If VMPP is set above the open-circuit voltage of the solar panel, it will never charge
      if (VMPP > MAX_VMPP || VMPP < MIN_VMPP) ++reverse;
 
      // Save newPower as lastPower
      lastPower = newPower;
 
    } while (reverse < 4); // Keep seeking maximum power point voltage (VMPP) until you have changed directions 4 times
 
 
    es2.setVMPP(VMPP - 100, 1); // Set VMPP back to last best setting and write to EEPROM so that it remembers the setting even if the sun is lost momentarily
    delay(1000); // Allow voltage to stabilize
 
    lastMillis = millis();
  }
}

void writeData(){
  
  // make a string for assembling the data to log:
  String jsonStart = "{";
  String tempK = "\"temperature\": ";
  String humidityK = "\"humidity\": ";
  String soilMoistureK = "\"moisture\": ";
  String date = "\"date\": ";
  String Time = "\"time\": ";
  String jsonEnd = "}\n"; 

  // read11 causes sensor to measure altered current electrical currents
  int chk = DHT.read11(DHT11_PIN);
  
  // sensor originally measure temp in C, so we converted to F
  float tempF = (DHT.temperature*1.8) + 32;
  float humidity = DHT.humidity;  // measured in %
  
  soilSensorValue = analogRead(soilSensorPin);
  soilPercentage = convertToPercentage(soilSensorValue);
  

  // open the file
  File dataFile = SD.open("dataLog.txt", FILE_WRITE);

  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(jsonStart);
    dataFile.print(tempK);
    dataFile.print(tempF);
    dataFile.println(",");
    dataFile.print(humidityK);
    dataFile.print(humidity);
    dataFile.println(",");
    dataFile.print(soilMoistureK);
    dataFile.print(soilPercentage);
    dataFile.println(",");
    dataFile.println(jsonEnd);
    dataFile.close();
  }

  // if soil moisture is below requirement begin watering for 5 mins
  if(soilPercentage < 75){
    waterGarden();  
  }
  
}
