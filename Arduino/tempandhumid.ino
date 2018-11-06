//libraries
#include <SoftwareSerial.h>
#include <dht.h>
#include <LiquidCrystal.h>

/*------------------------LCD Screen------------------------*/
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
/*----------------------------------------------------------*/

/*------------------------DHT SENSOR------------------------*/
dht DHT;              // Initialize the sensor
#define DHT11_PIN 7   // DHT (Humidity&Temp) data pin connected to Arduino's 7th pin
/*----------------------------------------------------------*/

/*------------------------ESP8266-01------------------------
Sensor currently only operates in the serial monitor after
passing individual AT commands. Currently working on programming 
the Arduino Board to automate the creation and set up of server,
so that we can then get sensor reading remotely and control
other modules.
//#define DEBUG true
//SoftwareSerial ESP8266 (0,1); //RX|TX
----------------------------------------------------------*/

void setup(){
  //Serial.begin(115200);
  //ESP8266.begin(115200);
  lcd.begin(16, 2);
  delay(1000);
}

void loop()
{ 
  // read11 causes sensor to measure altered current electrical currents
  int chk = DHT.read11(DHT11_PIN);
  // sensor originally measure temp in C, so we converted to F
  float tempF = (DHT.temperature*1.8)+32;
  float humidity = DHT.humidity;  // measured in %
  // lcd screen has only 2 rows
  lcd.setCursor(0,0); // sets cursor to print on first row first column
  lcd.print("Temp: ");
  lcd.print(tempF);
  lcd.print((char)223);
  lcd.print("F");
  lcd.setCursor(0,1); // sets cursor to print on second row first column
  lcd.print("Humidity: ");
  lcd.print(humidity);
  lcd.print("%");
  delay(2000);
}




