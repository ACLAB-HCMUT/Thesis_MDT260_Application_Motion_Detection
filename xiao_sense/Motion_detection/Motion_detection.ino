#include <LSM6DS3.h>
#include <nrf52840.h>
#include <Wire.h>
#include <bluefruit.h>
#include <Adafruit_LittleFS.h>
#include <InternalFileSystem.h>
#include "Motion-detection-with-XIAO-Sense_inferencing.h"

// Macro for IMU data
#define ACCELERATION_DUE_TO_GRAVITY 9.81f
#define GYRO_ANGLE_TO_RADIAN 3.141f / 180.0f

#define BLENAME "XIAO"
#define SERVICE_UUID "4D7D1101-EE27-40B2-836C-17505C1044D7"
#define TX_PRED_CHAR_UUID "4D7D1108-EE27-40B2-836C-17505C1044D7"

#define MAX_STRING_LENGTH 20

LSM6DS3 myIMU(I2C_MODE, 0x6A);  //I2C device address 0x6A

// Variable for normal mode
float features[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE] = { 0 };

String pre_motion = "idle";

#define PSIZE 30
String predictions[PSIZE];
int pCounter = 0;
int iData = 0;

long previousMillisSLEEP = 0;  // last time steps checked level was checked, in ms

float accX, accY, accZ, gX, gY, gZ;
int stepCount = 0;
bool UPDATED = false;

bool xbool = false;

const int SMOOTHING_WINDOW_SIZE = 80;  // # samples

int _samples[SMOOTHING_WINDOW_SIZE];  // the readings from the analog input
int _curReadIndex = 0;                // the index of the current reading
int _sampleTotal = 0;                 // the running total
int _sampleAvg = 0;                   // the average

bool CONNECTEDtoble = false;
bool isSubscribed = false;

BLEService myService(SERVICE_UUID);
BLECharacteristic MTNcharac(TX_PRED_CHAR_UUID);

void setupAccelerometer() {
  myIMU.begin();
  return;
}

void setupWakeUpInterrupt() {
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_MD1_CFG, 0x00);   // Power down the accelerometer
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_CTRL1_XL, 0x00);  // Disable double-tap interrupt
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_CTRL2_G, 0x00);

  /* Values from the application note */
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_CTRL2_G, 0x60);
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_CTRL1_XL, 0x60);     // Turn on the accelerometer
                                                            // ODR_XL = 416 Hz, FS_XL = ±2 g
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_TAP_CFG1, 0x8E);     // Enable interrupts and tap detection on X, Y, Z-axis
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_TAP_THS_6D, 0x8C);   // Set tap threshold
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_INT_DUR2, 0x7F);     // Set Duration, Quiet and Shock time windows
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_WAKE_UP_THS, 0x80);  // Single & double-tap enabled (SINGLE_DOUBLE_TAP = 1)
  myIMU.writeRegister(LSM6DS3_ACC_GYRO_MD1_CFG, 0x08);      // Double-tap interrupt driven to INT1 pin

  // Set up the sense mechanism to generate the DETECT signal to wake from system_off
  pinMode(PIN_LSM6DS3TR_C_INT1, INPUT_PULLDOWN_SENSE);

  return;
}

void setup() {
  Serial.begin(9600);  // open the serial port at 9600 bps:

  digitalWrite(LED_RED, LOW);
  digitalWrite(LED_GREEN, HIGH);

  setupAccelerometer();

  // Minimizes power when bluetooth is used
  NRF_POWER->DCDCEN = 1;

  Bluefruit.begin();
  Bluefruit.setName(BLENAME);

  // Set the connect/disconnect callback handlers
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  setupService();
  startAdv();

  if (!InternalFS.begin()) {
    Serial.println("Failed to mount InternalFS!");
    while (1) { delay(10); }
  }
  Serial.println("InternalFS mounted.");
}

void startAdv(void) {
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.autoConnLed(false);

  Bluefruit.Advertising.addService(myService);

  // Include Name
  Bluefruit.Advertising.addName();

  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);  // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);    // number of seconds in fast mode
  Bluefruit.Advertising.start(0);              // 0 = Don't stop advertising after n seconds
}

void setupService(void) {
  myService.begin();

  MTNcharac.setProperties(CHR_PROPS_NOTIFY);
  MTNcharac.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  MTNcharac.setMaxLen(20);
  MTNcharac.begin();

  MTNcharac.setCccdWriteCallback(cccd_callback);
}

void connect_callback(uint16_t conn_handle) {
  CONNECTEDtoble = true;
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_RED, HIGH);
}

void disconnect_callback(uint16_t conn_handle, uint8_t reason) {
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_RED, LOW);

  CONNECTEDtoble = false;
  isSubscribed = false;
  (void)conn_handle;
  (void)reason;
}

void cccd_callback(uint16_t conn_hdl, BLECharacteristic* chr, uint16_t cccd_value) {
  if (chr->uuid == MTNcharac.uuid) {
    Serial.print("CCCD Updated: ");

    if (cccd_value == 0) {
      Serial.println("Notifications disabled");
      isSubscribed = false;
    } else if (cccd_value == 1) {
      Serial.println("Notifications enabled");
      isSubscribed = true;
    } else if (cccd_value == 3) {
      Serial.println("Notifications & Indications enabled");
      isSubscribed = true;
    }
  }
}

void loop() {
  delay(10);
  String currentMotion;
  long currentMillis = millis();
  if (currentMillis - previousMillisSLEEP >= 60000 && CONNECTEDtoble == false) {
    goToPowerOff();
  }

  accX = myIMU.readFloatAccelX();
  accY = myIMU.readFloatAccelY();
  accZ = myIMU.readFloatAccelZ();
  gX = myIMU.readFloatGyroX();
  gY = myIMU.readFloatGyroY();
  gZ = myIMU.readFloatGyroZ();
  // Làm mượt gyro Y
  _sampleTotal = _sampleTotal - _samples[_curReadIndex];
  _samples[_curReadIndex] = gY;
  _sampleTotal = _sampleTotal + _samples[_curReadIndex];
  _curReadIndex = (_curReadIndex + 1) % SMOOTHING_WINDOW_SIZE;
  _sampleAvg = _sampleTotal / SMOOTHING_WINDOW_SIZE;
  if (xbool == false && _sampleAvg < -30) {
    xbool = true;
  } else if (xbool == true && _sampleAvg > -30) {
    xbool = false;
    stepCount += 2;
    previousMillisSLEEP = millis();
  }
  collect_data();
  // Serial.println(millis());
  if (iData == EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE) {
    currentMotion = run_detection();
    iData = 0;

    if (CONNECTEDtoble == true && isSubscribed == true) {
      previousMillisSLEEP = millis();
      char motionBuffer[MAX_STRING_LENGTH] = { 0 };
      if (currentMotion == "stepping_stair") {
        currentMotion = "stepping";
      }
      snprintf(motionBuffer, MAX_STRING_LENGTH - 1, "%s %i", currentMotion.c_str(), stepCount);
      stepCount = 0;
      Serial.println(motionBuffer);
      if (fileHasData("/motion_log.txt")) {
        readData("/motion_log.txt");
        deleteFile("/motion_log.txt");
        delay(2000);
      }
      MTNcharac.notify((uint8_t*)motionBuffer, strlen(motionBuffer));
      if (pCounter != 0) {
        pCounter = 0;
      }
    } else {
      predictions[pCounter++] = currentMotion;
      Serial.print(currentMotion);
      Serial.print(" ");
      Serial.println(stepCount);
      if (pCounter == PSIZE) {
        pCounter = 0;
        String finalMotion = getFinalPrediction();
        if (finalMotion == "stepping_stair") {
          finalMotion = "stepping";
        }
        char motionBuffer[MAX_STRING_LENGTH];
        snprintf(motionBuffer, MAX_STRING_LENGTH - 1, "%s %i", finalMotion.c_str(), stepCount);
        stepCount = 0;
        Serial.println(motionBuffer);
        writeData("/motion_log.txt", (uint8_t*)motionBuffer, strlen(motionBuffer));
      }
    }
  }
}

void goToPowerOff() {
  Serial.println("Sleep mode");
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_RED, HIGH);
  // Setup up double tap interrupt to wake back up
  setupWakeUpInterrupt();
  NRF_POWER->SYSTEMOFF = 1; 
}

int raw_feature_get_data(size_t offset, size_t length, float* out_ptr) {
  memcpy(out_ptr, features + offset, length * sizeof(float));
  return 0;
}

void collect_data() {
  features[iData] = accX * ACCELERATION_DUE_TO_GRAVITY;
  features[iData + 1] = accY * ACCELERATION_DUE_TO_GRAVITY;
  features[iData + 2] = accZ * ACCELERATION_DUE_TO_GRAVITY;
  features[iData + 3] = gX * GYRO_ANGLE_TO_RADIAN;
  features[iData + 4] = gY * GYRO_ANGLE_TO_RADIAN;
  features[iData + 5] = gZ * GYRO_ANGLE_TO_RADIAN;
  iData = iData + 6;
}

String run_detection() {
  // Run the classifier
  ei_impulse_result_t result = { 0 };

  signal_t features_signal;
  features_signal.total_length = sizeof(features) / sizeof(features[0]);
  features_signal.get_data = &raw_feature_get_data;

  // Invoke the impulse
  EI_IMPULSE_ERROR res = run_classifier(&features_signal, &result, false /* debug */);
  if (res != EI_IMPULSE_OK)
    return pre_motion;

  float score = 0;
  String label = "";
  // Get result after classifier
  for (size_t ix = 0; ix < EI_CLASSIFIER_LABEL_COUNT; ix++) {
    if (result.classification[ix].value > score) {
      score = result.classification[ix].value;
      label = result.classification[ix].label;
    }
  }

  // if (score > 0.7) {
    pre_motion = label;
  // }

  return pre_motion;
}

String getFinalPrediction() {
  int idle = 0;
  int walking = 0;
  int running = 0;
  int stepping_stair = 0;

  String finalLabel = "1";

  for (int i = 0; i < PSIZE; i++) {

    String label = predictions[i];

    if (label == "idle") {
      idle++;
    } else if (label == "walking") {
      walking++;
    } else if (label == "running") {
      running++;
    } else if (label == "stepping_stair") {
      stepping_stair++;
    }
  }

  if (stepping_stair > PSIZE / 3) {
    finalLabel = "stepping_stair";
  } else if (running > PSIZE / 3) {
    finalLabel = "running";
  } else if (walking > PSIZE / 3) {
    finalLabel = "walking";
  } else {
    finalLabel = "idle";
  }
  return finalLabel;
}

bool fileHasData(const char* filename) {
  using namespace Adafruit_LittleFS_Namespace;
  File myFile(InternalFS);

  if (!myFile.open(filename, FILE_O_READ)) {
    Serial.println("File does not exist");
    return false;
  }

  size_t fileSize = myFile.size();
  myFile.close();

  if (fileSize > 0) {
    Serial.print("File size: ");
    Serial.print(fileSize);
    Serial.println(" bytes. Data available.");
    return true;
  } else {
    Serial.println("File exists but is empty");
    return false;
  }
}

void deleteFile(const char* filename) {
  if (InternalFS.remove(filename)) {
    Serial.println("File deleted successfully");
  } else {
    Serial.println("Failed to delete file");
  }
}

void writeData(const char* filename, const uint8_t* data, size_t length) {
  using namespace Adafruit_LittleFS_Namespace;
  File myFile(InternalFS);

  myFile.open(filename, FILE_O_WRITE);
  if (!myFile) {
    Serial.println("Failed to open file for writing.");
    return;
  }
  myFile.seek(myFile.size());
  myFile.write(data, length);
  myFile.write('\n');
  myFile.close();
  Serial.println("Data written to flash.");
}

void readData(const char* filename) {
  using namespace Adafruit_LittleFS_Namespace;
  File myFile(InternalFS);

  myFile.open(filename, FILE_O_READ);
  if (!myFile) {
    Serial.println("Failed to open file for reading.");
    return;
  }

  const int bufferSize = 20;
  char buffer[bufferSize] = { 0 };
  int bytesRead = 0;

  Serial.println("Reading data from flash...");

  while (myFile.available()) {
    // Xóa buffer
    memset(buffer, 0, bufferSize);
    bytesRead = 0;

    while (myFile.available() && bytesRead < bufferSize - 1) {
      char c = myFile.read();
      if (c == '\n' || c == '\r') {
        break;
      }
      buffer[bytesRead++] = c;
    }

    if (bytesRead > 0) {
      Serial.println(buffer);
      MTNcharac.notify((uint8_t*)buffer, bytesRead);
      delay(20);
    }

    while (myFile.available()) {
      char c = myFile.read();
      if (c != '\n' && c != '\r') {
        myFile.seek(myFile.position() - 1);
        break;
      }
    }
  }

  myFile.close();
  Serial.println("Data read complete.");
}
