// Include the necessary libraries
#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_VL53L0X.h>
#include <HardwareSerial.h>

// Instantiate an object for the sensor
Adafruit_VL53L0X lox = Adafruit_VL53L0X();

HardwareSerial SerialPort(2); // use UART2

const int signal1 = 35;
const int signal0 = 34;
int characterToSend1;
int characterToSend0;

void setup() {
  // Initialize FPGA signals of serial send
  pinMode(signal1, INPUT);
  pinMode(signal0, INPUT);
  // Initialize Serial communication in pins
  SerialPort.begin(115200, SERIAL_8N2, 16, 17); 
  // Initialize Serial communication for debugging
  Serial.begin(115200);
  Serial.println("VL53L0X Test");
  // Initialize the sensor
  if(!lox.begin()) {
    Serial.println("Failed to initialize VL53L0X");
    while(1);
  }
}

void loop() {
  // Declare variables for storing the sensor data
  VL53L0X_RangingMeasurementData_t value;
  String output;
  // Variable that comes from FPGA
  characterToSend1 = digitalRead(signal1);
  characterToSend0 = digitalRead(signal0);
  // Get the sensor data
  Serial.print("Reading a measurement...");
  lox.rangingTest(&value, false);
  uint16_t valueCentimeter = value.RangeMilliMeter/10;
  // If we get a valid measurement, send it to the screen
  if(value.RangeStatus != 4) {
    if(characterToSend1 == 1 && characterToSend0 == 1){
        SerialPort.print(String(valueCentimeter/100));
        //Serial.println(String(valueCentimeter/100));
    } else if (characterToSend1 == 1 && characterToSend0 == 0){
        SerialPort.print(String((valueCentimeter%100)/10));
        //Serial.println(String((valueCentimeter%100)/10));
    } else if (characterToSend1 == 0 && characterToSend0 == 1){
        SerialPort.print(String(valueCentimeter%10));
        //Serial.println(String(valueCentimeter%10));
    }
    // SerialPort.print(String(value.RangeMilliMeter) + " ");
    output = String(valueCentimeter) + " cm";
    Serial.print("Distance: ");
    Serial.println(output);
  } else {
    Serial.println(" Out of range! ");
  }
  // Wait a bit before the next measurement
  delay(100);
}
