///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Project: Code from Github issue https://github.com/esp8266/Arduino/issues/1032#issuecomment-273441710 //
// Original Code Author: ninjabe86 https://github.com/ninjabe86                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////
// Libraries Included //
////////////////////////
#include <Arduino.h>
#include <ESP8266WiFi.h>
#ifdef ESP8266
extern "C" {
#include "user_interface.h"
#include "wpa2_enterprise.h"
}
#endif

///////////////////////////////////
// WiFi WPA2 Network Parameters  //
///////////////////////////////////
static u8 ent_username[] = "schoolemail"; // same as the mdoification to lipwpa2.a file
static u8 ent_password[] = "password";

void setup(){
  pinMode(LED_BUILTIN, OUTPUT);
  char a[100];
  ip_info info;
  wifi_get_ip_info(0, &info);

  // Serial Monitor is used to control the demo and view
  // debug information.
  Serial.begin(9600); // listen on serial monitor channel 9600 baud

  // Ensure WiFi is disconnected of any other prior networks
  wifi_station_disconnect();
  // Set up WiFi mode
  wifi_set_opmode(STATION_MODE);

  // Wifi network's name and password
  char ssid[32] = "eduroam";
  char password[64] = {0x00};

  // Construct and initialize station's configurations
  struct station_config stationConf;
  stationConf.bssid_set = 0;
  memcpy(&stationConf.ssid, ssid, 32);
  memcpy(&stationConf.password, password, 64);

  // check if configuration settings work
  if(!wifi_station_set_config(&stationConf)){
    Serial.print("\r\nset config fail\r\n");
  }

  // set station to WPA2 Enterprise connection
  wifi_station_set_wpa2_enterprise_auth(1); 

  // check if username setting worked
  if(wifi_station_set_enterprise_username (ent_username, strlen((char*)ent_username))){
    Serial.print("\r\nusername set fail\r\n");
  }

  // check if password setting worked
  if(wifi_station_set_enterprise_password (ent_password, strlen((char*)ent_password))){
    Serial.print("\r\npassword set fail\r\n");
  }

  // check if station connected
  if(!wifi_station_connect()){
    Serial.print("\r\nconnect fail\r\n");
  }

  Serial.print("\r\ntrying to connect...");

  // get WiFi status
  while(info.ip.addr == 0){
    ESP.wdtFeed();
    Serial.print(".");
    delay(1000);
    wifi_get_ip_info(0, &info);
  }

  // print ip address
  sprintf(a, "%"PRIu32,info.ip.addr);
  Serial.print("\r\nip addr: ");
  Serial.print(a);
  Serial.print("\r\n");
}

// loop function is needed; can remain empty if not used
void loop()
{ 
  
}
