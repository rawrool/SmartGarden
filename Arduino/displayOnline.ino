////////////////////////
// Libraries Included //
////////////////////////
#include <SoftwareSerial.h>       // Allows serial communication on 0 and 1 digital pins of the Arduino
#include <SparkFunESP8266WiFi.h>  // Specific library created by SparkFun for their ESP8266 WiFi Shield
#include <dht.h>                  // Library for temperature and humidity sensor
#include <LiquidCrystal.h>        // Library for LCD screen

//////////////////////////////
// WiFi Network Parameters  //
//////////////////////////////
const char mySSID[] = "";    // network's name
const char myPSK[] = "";  // password for the network

//////////////////////////////
// ESP8266Server Definition //
//////////////////////////////
ESP8266Server server = ESP8266Server(80); // server object created on port 80

//////////////////////////////
// LCD Screen Pin Set-up    //
//////////////////////////////
LiquidCrystal lcd(11, 12, 2, 3, 4, 5);

//////////////////////////////
// DHT Sensor Definition    //
//////////////////////////////
dht DHT;              // Initialize the sensor
#define DHT11_PIN 7   // DHT (Humidity&Temp) data pin connected to Arduino's 7th pin

////////////////////////////////////////
// Water Solenoid Valve Pin Set-up    //
////////////////////////////////////////
int waterPin = 6;

//////////////////
// HTTP Strings //
//////////////////
const char destServer[] = "example.com";
const String htmlHeader = "HTTP/1.1 200 OK\r\n"
                          "Content-Type: text/html\r\n"
                          "Connection: close\r\n\r\n"
                          "<!DOCTYPE HTML>\r\n"
                          "<html>\r\n";

const String httpRequest = "GET / HTTP/1.1\n"
                           "Host: example.com\n"
                           "Connection: close\n\n";


////////////////////////////////////////
//   Soil Moisture Sensor Variables   //
////////////////////////////////////////
int soilSensorPin = A0;
int soilSensorValue = 0;
int soilPercentage = 0;


void setup() 
{
  // begin LCD display
  lcd.begin(16, 2); // parameter is size of screen
  delay(1000);
  
  // Serial Monitor is used to control the demo and view
  // debug information.
  Serial.begin(9600); // listen on serial monitor channel 9600 baud
  serialTrigger(F("Press any key to begin.")); // prints and listen on serial monitor

  // initializeESP8266() verifies communication with the WiFi
  // shield, and sets it up.
  initializeESP8266();

  // connectESP8266() connects to the defined WiFi network.
  connectESP8266();

  // displayConnectInfo prints the Shield's local IP
  // and the network it's connected to.
  displayConnectInfo();

  serialTrigger(F("Press any key to connect client."));
  clientDemo();
  
  serialTrigger(F("Press any key to test server."));
  serverSetup();

  // set pin for water solenoid valve as output
  pinMode(waterPin, OUTPUT);   
}

void loop() 
{
  serverDemo();
  displayOnLCD();
  displaySoilMoistureToLCD();
  waterGarden(10);
}

void initializeESP8266()
{
  // esp8266.begin() verifies that the ESP8266 is operational
  // and sets it up for the rest of the sketch.
  // It returns either true or false -- indicating whether
  // communication was successul or not.
  // true
  int test = esp8266.begin();
  if (test != true)
  {
    Serial.println(F("Error talking to ESP8266."));
    errorLoop(test);
  }
  Serial.println(F("ESP8266 Shield Present"));
}

void connectESP8266()
{
  // The ESP8266 can be set to one of three modes:
  //  1 - ESP8266_MODE_STA - Station only
  //  2 - ESP8266_MODE_AP - Access point only
  //  3 - ESP8266_MODE_STAAP - Station/AP combo
  // Use esp8266.getMode() to check which mode it's in:
  int retVal = esp8266.getMode();
  if (retVal != ESP8266_MODE_STA)
  { // If it's not in station mode.
    // Use esp8266.setMode([mode]) to set it to a specified
    // mode.
    retVal = esp8266.setMode(ESP8266_MODE_STA);
    if (retVal < 0)
    {
      Serial.println(F("Error setting mode."));
      errorLoop(retVal);
    }
  }
  Serial.println(F("Mode set to station"));

  // esp8266.status() indicates the ESP8266's WiFi connect
  // status.
  // A return value of 1 indicates the device is already
  // connected. 0 indicates disconnected. (Negative values
  // equate to communication errors.)
  retVal = esp8266.status();
  if (retVal <= 0)
  {
    Serial.print(F("Connecting to "));
    Serial.println(mySSID);
    // esp8266.connect([ssid], [psk]) connects the ESP8266
    // to a network.
    // On success the connect function returns a value >0
    // On fail, the function will either return:
    //  -1: TIMEOUT - The library has a set 30s timeout
    //  -3: FAIL - Couldn't connect to network.
    retVal = esp8266.connect(mySSID, myPSK);
    if (retVal < 0)
    {
      Serial.println(F("Error connecting"));
      errorLoop(retVal);
    }
  }
}

void displayConnectInfo()
{
  char connectedSSID[24];
  memset(connectedSSID, 0, 24);
  // esp8266.getAP() can be used to check which AP the
  // ESP8266 is connected to. It returns an error code.
  // The connected AP is returned by reference as a parameter.
  int retVal = esp8266.getAP(connectedSSID);
  if (retVal > 0)
  {
    Serial.print(F("Connected to: "));
    Serial.println(connectedSSID);
  }

  // esp8266.localIP returns an IPAddress variable with the
  // ESP8266's current local IP address.
  IPAddress myIP = esp8266.localIP();
  Serial.print(F("My IP: ")); Serial.println(myIP);
}

void clientDemo()
{
  // To use the ESP8266 as a TCP client, use the 
  // ESP8266Client class. First, create an object:
  ESP8266Client client;

  // ESP8266Client connect([server], [port]) is used to 
  // connect to a server (const char * or IPAddress) on
  // a specified port.
  // Returns: 1 on success, 2 on already connected,
  // negative on fail (-1=TIMEOUT, -3=FAIL).
  int retVal = client.connect(destServer, 80);
  if (retVal <= 0)
  {
    Serial.println(F("Failed to connect to server."));
    return;
  }

  // print and write can be used to send data to a connected
  // client connection.
  client.print(httpRequest);

  // available() will return the number of characters
  // currently in the receive buffer.
  while (client.available())
    Serial.write(client.read()); // read() gets the FIFO char
  
  // connected() is a boolean return value - 1 if the 
  // connection is active, 0 if it's closed.
  if (client.connected())
    client.stop(); // stop() closes a TCP connection.
}

void serverSetup()
{
  // begin initializes a ESP8266Server object. It will
  // start a server on the port specified in the object's
  // constructor (in global area)
  server.begin();
  Serial.print(F("Server started! Go to "));
  Serial.println(esp8266.localIP());
  Serial.println();
}

void serverDemo()
{
  // available() is an ESP8266Server function which will
  // return an ESP8266Client object for printing and reading.
  // available() has one parameter -- a timeout value. This
  // is the number of milliseconds the function waits,
  // checking for a connection.
  ESP8266Client client = server.available(500);
  
  if (client) 
  {
    Serial.println(F("Client Connected!"));
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) 
    {
      if (client.available()) 
      {
        char c = client.read();
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) 
        {
          // read11 causes sensor to measure altered current electrical currents
          int chk = DHT.read11(DHT11_PIN);
          // sensor originally measure temp in C, so we converted to F
          float tempF = (DHT.temperature*1.8) + 32;
          float humidity = DHT.humidity;  // measured in %
          Serial.println(F("Sending HTML page"));
          // send a standard http response header:
          client.print(htmlHeader);
          String htmlBody;
          // output the value of each analog input pin
          htmlBody += "Temp: ";
          htmlBody += String(tempF);
          htmlBody += "<br>\n";
          htmlBody += "Humidity: ";
          htmlBody += String(humidity);
          htmlBody += "<br>\n";
          htmlBody += "</html>\n";
          client.print(htmlBody);
          break;
        }
        if (c == '\n') 
        {
          // you're starting a new line
          currentLineIsBlank = true;
        }
        else if (c != '\r') 
        {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
   
    // close the connection:
    client.stop();
    Serial.println(F("Client disconnected"));
  }
  
}

// errorLoop prints an error code, then loops forever.
void errorLoop(int error)
{
  Serial.print(F("Error: ")); Serial.println(error);
  Serial.println(F("Looping forever."));
  for (;;)
    ;
}

// serialTrigger prints a message, then waits for something
// to come in from the serial port.
void serialTrigger(String message)
{
  Serial.println();
  Serial.println(message);
  Serial.println();
  while (!Serial.available())
    ;
  while (Serial.available())
    Serial.read();
}

void displayOnLCD()
{
  // read11 causes sensor to measure altered current electrical currents
  int chk = DHT.read11(DHT11_PIN);
  // sensor originally measure temp in C, so we converted to F
  float tempF = (DHT.temperature*1.8) + 32;
  float humidity = DHT.humidity;  // measured in %
  // clear lcd screen
  lcd.clear();
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

int convertToPercentage(int value)
{
  int percentValue = 0;
  percentValue = map(value, 1023, 465, 0, 100);
  return percentValue;
}

void displaySoilMoistureToLCD()
{
  soilSensorValue = analogRead(soilSensorPin);
  soilPercentage = convertToPercentage(soilSensorValue);
  // clear lcd screen
  lcd.clear();
  lcd.setCursor(0,0); // sets cursor to print on first row first column
  lcd.print("Soil Value: ");
  lcd.print(soilSensorValue);
  lcd.setCursor(0,1); // sets cursor to print on second row first column
  lcd.print("Soil %: ");
  lcd.print(soilPercentage);
  lcd.print("%");
  delay(3000);
}

void waterGarden(int seconds)
{
  // convert seconds to ms
  int timeInSeconds = seconds*1000;
  digitalWrite(waterPin, HIGH);  //Switch Solenoid ON
  delay(timeInSeconds);          //Delay for set amount of time before turning off 
  digitalWrite(waterPin, LOW);   //Switch Solenoid OFF
  delay(1000);                   //Wait 1 Second
}
