/*
 * =========================================================================
 * SMARTWASTE IOT SENSOR - ESP32 DIRECT WI-FI TELEMETRY
 * Project: Smart Waste Management System (FPT University HCM - PRJ301)
 * Hardware: ESP32 NodeMCU + HC-SR04 Ultrasonic Sensor
 * Target API: POST http://<SERVER_IP>:8080/SmartWaste/api/bin/update-fill
 * =========================================================================
 */

#include <WiFi.h>
#include <HTTPClient.h>

// =========================================================================
// 1. CẤU HÌNH WI-FI & ĐỊA CHỈ SERVER
// =========================================================================
// Nhập tên và mật khẩu Wi-Fi (Khuyên dùng Wi-Fi phát từ 4G điện thoại hoặc Wi-Fi nhà 2.4GHz)
const char* WIFI_SSID     = "ESP32_TEST";
const char* WIFI_PASSWORD = "esp32test123";

// Địa chỉ máy tính đang chạy Tomcat (IP mạng Wi-Fi hiện tại của máy tính: 10.223.183.173)
const char* SERVER_URL    = "http://10.137.142.173:8080/SmartWaste/api/bin/update-fill";

// =========================================================================
// 2. THÔNG SỐ THÙNG RÁC DEMO (MINI CAO 20CM, LÒNG THÙNG ~ 2.0L)
// =========================================================================
// Mã thùng rác trong SmartWasteDB
const char* BIN_ID        = "BIN-001";

// Chiều cao lòng thùng rác mini tính bằng cm (từ cảm biến nắp xuống đáy thùng = 20.0 cm)
// Khi khoảng cách >= 150.0 cm (thùng rỗng hoặc quét phòng trống) -> 0% (Trống hoàn toàn)
const float BIN_DEPTH_CM  = 15.0;

// Khoảng cách mù tối thiểu của cảm biến siêu âm (~ 2.0 cm sát cảm biến -> 100% Đầy tràn)
const float MIN_DIST_CM   = 2.0;

// Chu kỳ gửi dữ liệu về Server (3000ms = 3 giây/lần cho demo mượt mà)
const unsigned long SEND_INTERVAL_MS = 3000;
unsigned long lastSendTime = 0;

// =========================================================================
// 3. ĐỊNH NGHĨA CHÂN CẮM CẢM BIẾN (4 DÂY CẦN THIẾT)
// =========================================================================
const int TRIG_PIN = 5;   // Nối với chân TRIG của HC-SR04 (ký hiệu D5 hoặc 5 trên ESP32)
const int ECHO_PIN = 18;  // Nối với chân ECHO của HC-SR04 (ký hiệu D18 hoặc 18 trên ESP32)

// =========================================================================
// KHỞI ĐỘNG HỆ THỐNG
// =========================================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);

  Serial.println("\n=============================================");
  Serial.println("   SMARTWASTE - ESP32 WI-FI IOT SENSOR NODE   ");
  Serial.println("=============================================");

  connectWiFi();
}

// Hàm kết nối Wi-Fi tự động
void connectWiFi() {
  Serial.print("[WIFI] Dang ket noi toi: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WIFI] Ket noi thanh cong!");
    Serial.print("[WIFI] Dia chi IP ESP32: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[WIFI] Chua ket noi duoc. Se tu thu lai trong vong lap.");
  }
}

// Hàm đo khoảng cách bằng sóng siêu âm (đơn vị: cm)
float measureDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Đo thời gian xung Echo phản hồi về (timeout 30000us ~ 5 mét)
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  if (duration == 0) {
    return -1.0; // Lỗi cảm biến hoặc ngoài tầm quét
  }

  // Tốc độ âm thanh: 343m/s = 0.0343 cm/microsecond
  float distance = (duration * 0.0343) / 2.0;
  return distance;
}

// Hàm gửi HTTP POST trực tiếp về Server SmartWaste
void sendDataToSmartWaste(int fillPercent, float distanceCm) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[WIFI] Mat ket noi. Dang thu ket noi lai...");
    connectWiFi();
    return;
  }

  HTTPClient http;
  http.begin(SERVER_URL);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  // Dữ liệu HTTP POST dạng URL-encoded chuẩn: binID=BIN-001&fillPercent=85
  String postData = "binID=" + String(BIN_ID) + "&fillPercent=" + String(fillPercent);

  Serial.println("[HTTP] Gui du lieu toi: " + String(SERVER_URL));
  Serial.printf("[HTTP] Thung: %s | Muc rac: %d%% | Khoang cach do duoc: %.1f cm\n", BIN_ID, fillPercent, distanceCm);

  int httpResponseCode = http.POST(postData);

  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.printf("[HTTP] Thanh cong (HTTP %d) -> Server phan hoi: %s\n", httpResponseCode, response.c_str());
  } else {
    Serial.printf("[HTTP] POST gap loi (%s), thu chuyen sang GET...\n", http.errorToString(httpResponseCode).c_str());
    http.end();
    String getUrl = String(SERVER_URL) + "?" + postData;
    http.begin(getUrl);
    httpResponseCode = http.GET();
    if (httpResponseCode > 0) {
      Serial.printf("[HTTP] GET thanh cong (HTTP %d) -> Server phan hoi: %s\n", httpResponseCode, http.getString().c_str());
    } else {
      Serial.printf("[HTTP ERROR] Gui that bai ca POST va GET! Ma loi: %s (%d)\n", http.errorToString(httpResponseCode).c_str(), httpResponseCode);
    }
  }

  http.end();
}

// =========================================================================
// VÒNG LẶP CHÍNH
// =========================================================================
void loop() {
  unsigned long currentMillis = millis();

  if (currentMillis - lastSendTime >= SEND_INTERVAL_MS) {
    lastSendTime = currentMillis;

    // Lay 3 mau do lien tiep de khu nhieu
    float totalDist = 0.0;
    int validSamples = 0;

    for (int i = 0; i < 3; i++) {
      float d = measureDistanceCm();
      // Chap nhan moi khoang cach phan hoi hop le (duoi 400cm / 4m)
      if (d > 0.0 && d <= 400.0) {
        totalDist += d;
        validSamples++;
      }
      delay(30);
    }

    if (validSamples > 0) {
      float avgDistance = totalDist / validSamples;

      // Neu khoang cach >= BIN_DEPTH_CM (khong co rac hoac phong trong): Muc rac = 0% (Rong)
      float fill = 0.0;
      if (avgDistance <= MIN_DIST_CM) {
        fill = 100.0; // Vat can sat mat cam bien (<= 3cm) -> Day 100%
      } else if (avgDistance >= BIN_DEPTH_CM) {
        fill = 0.0;   // Khong co vat can hoac cham day thung -> Rong 0%
      } else {
        fill = ((BIN_DEPTH_CM - avgDistance) / (BIN_DEPTH_CM - MIN_DIST_CM)) * 100.0;
      }

      // Khu nhieu nhe o day thung (duoi 3% coi nhu thung rong 0%)
      if (fill <= 3.0) fill = 0.0;
      if (fill > 100.0) fill = 100.0;

      int fillPercent = (int)(fill + 0.5);

      Serial.println("---------------------------------------------");
      Serial.printf("[SENSOR] Khoang cach thuc te: %.1f cm | Muc rac tinh toan: %d%%\n", avgDistance, fillPercent);

      // In chuoi JSON ra Serial de co the dung USB Bridge khi khong co Wi-Fi
      Serial.printf("{\"bin_id\":\"%s\",\"distance_cm\":%.1f,\"fill_level\":%d}\n", BIN_ID, avgDistance, fillPercent);

      // Ban du lieu ve Server qua Wi-Fi
      sendDataToSmartWaste(fillPercent, avgDistance);
    } else {
      Serial.println("[SENSOR WARNING] Khong doc duoc cam bien. Kiem tra lai 4 day noi (VCC 5V, GND, TRIG GPIO5, ECHO GPIO18)!");
    }
  }
}
