/*
 * =========================================================================
 * SMARTWASTE IOT SENSOR - ARDUINO UNO + HC-SR04
 * Project: Smart Waste Management System (PRJ301)
 * Hardware: Arduino Uno R3, HC-SR04 Ultrasonic Sensor
 * Output: Serial JSON string every 2 seconds
 * =========================================================================
 */

// Pin definitions
const int TRIG_PIN = 9;   // Connect to HC-SR04 Trig pin
const int ECHO_PIN = 10;  // Connect to HC-SR04 Echo pin

// Bin identification in SmartWaste database (e.g. BIN-001, BIN-002, etc.)
const char* BIN_ID = "BIN-001";

// Total height of the waste bin in centimeters (sensor to bottom)
// Adjust this value according to your demo trash bin depth
const float BIN_DEPTH_CM = 20.0;

// Minimum blind-spot distance for HC-SR04 (usually 3 - 4 cm)
const float MIN_DISTANCE_CM = 2.0;

void setup() {
  // Initialize Serial communication at 9600 baud rate
  Serial.begin(9600);
  
  // Set pin modes
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Ensure trigger pin starts LOW
  digitalWrite(TRIG_PIN, LOW);
  delay(200);

  // Ready indicator
  Serial.println("{\"status\":\"READY\",\"device\":\"SmartWaste_Uno_Sensor\"}");
}

// Function to measure distance in centimeters
float measureDistanceCm() {
  // Clear trigger pin
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  // Send a 10-microsecond HIGH pulse
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Read echo pulse duration in microseconds (timeout at 30,000us ~ 5 meters)
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);

  if (duration == 0) {
    return -1.0; // Reading timeout or sensor error
  }

  // Speed of sound = 343 m/s = 0.0343 cm/microsecond
  // Distance = (time * speed) / 2
  float distance = (duration * 0.0343) / 2.0;
  return distance;
}

void loop() {
  // Take 3 sample measurements to filter noise
  float totalDistance = 0.0;
  int validSamples = 0;

  for (int i = 0; i < 3; i++) {
    float d = measureDistanceCm();
    if (d > 0.0 && d <= (BIN_DEPTH_CM + 20.0)) {
      totalDistance += d;
      validSamples++;
    }
    delay(40);
  }

  if (validSamples > 0) {
    float avgDistance = totalDistance / validSamples;

    // Clamp distance within realistic bounds
    if (avgDistance < MIN_DISTANCE_CM) {
      avgDistance = MIN_DISTANCE_CM;
    }
    if (avgDistance > BIN_DEPTH_CM) {
      avgDistance = BIN_DEPTH_CM;
    }

    // Calculate fill percentage: 0% (empty) to 100% (full)
    float fillPercentage = ((BIN_DEPTH_CM - avgDistance) / (BIN_DEPTH_CM - MIN_DISTANCE_CM)) * 100.0;
    
    // Bounds check
    if (fillPercentage < 0.0) fillPercentage = 0.0;
    if (fillPercentage > 100.0) fillPercentage = 100.0;

    int fillRounded = (int)(fillPercentage + 0.5);

    // Output clean JSON format to Serial port
    Serial.print("{\"bin_id\":\"");
    Serial.print(BIN_ID);
    Serial.print("\",\"distance_cm\":");
    Serial.print(avgDistance, 1);
    Serial.print(",\"fill_level\":");
    Serial.print(fillRounded);
    Serial.println("}");

  } else {
    // Sensor reading error
    Serial.print("{\"bin_id\":\"");
    Serial.print(BIN_ID);
    Serial.println("\",\"error\":\"SENSOR_TIMEOUT\"}");
  }

  // Interval between telemetry transmissions (2 seconds)
  delay(2000);
}
