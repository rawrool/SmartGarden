#include <NS_energyShield2.h>
#include <NS_eS2_Utilities.h>

NS_energyShield2 nsPower; 

void setup() {
  
  nsPower.begin(); // Initializes the energyShield 2 
  nsPower.setVMPP(17500,0); // Set solar panel Maximum Power Point Voltage (VMPP) regulation to 17.5V
  
}

void loop() {

}
