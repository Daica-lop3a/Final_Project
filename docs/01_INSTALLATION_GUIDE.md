# 01. HƯỚNG DẪN CÀI ĐẶT & TRIỂN KHAI HỆ THỐNG (INSTALLATION & DEPLOYMENT GUIDE)
## ĐỒ ÁN MÔN HỌC PRJ301 – ĐẠI HỌC FPT TP. HỒ CHÍ MINH
### HỆ THỐNG QUẢN LÝ THÙNG RÁC THÔNG MINH SMARTWASTE (PHIÊN BẢN 2.0 - ESP32 WI-FI)

---

## 1. Yêu Cầu Môi Trường & Phần Mềm Tiên Quyết (System Requirements)

Hệ thống được kiểm thử và vận hành ổn định trên môi trường tiêu chuẩn của môn PRJ301:
* **Hệ điều hành:** Microsoft Windows 10 / 11 (64-bit).
* **Nền tảng Java Core:** Java Development Kit (JDK) 1.8 (Khuyến nghị: `jdk1.8.0_172` hoặc `jdk1.8.0_202`).
* **Hệ quản trị Cơ sở dữ liệu:** Microsoft SQL Server 2014 / 2016 / 2017 / 2019 / 2022 (Developer hoặc Express Edition) đã bật chế độ **SQL Server Authentication**.
* **Máy chủ ứng dụng Web (Web Server):** Apache Tomcat 9.0.x (Thực nghiệm trên: `apache-tomcat-9.0.113`).
* **Môi trường phát triển IDE (Tùy chọn):** Apache NetBeans 12+ / NetBeans 8.2 hoặc Eclipse for Enterprise Java Developers.
* **Môi trường lập trình phần cứng IoT:** Arduino IDE 1.8.x hoặc Arduino IDE 2.x (Hỗ trợ nạp ESP32 Board package).
* **Phần cứng IoT:** 
  * Bo mạch vi điều khiển **ESP32 NodeMCU (WROOM-32)**.
  * Cảm biến đo khoảng cách siêu âm **HC-SR04** (Nguồn 5V DC).
  * 4 dây cắm Breadboard cái - cái (Female-to-Female).
  * Cáp nạp Micro-USB kết nối máy tính hoặc củ sạc 5V.

---

## 2. Thiết Lập Cơ Sở Dữ Liệu SQL Server (Database Setup)

Toàn bộ CSDL `SmartWasteDB` được lưu trữ tại thư mục dự án qua các file SQL kịch bản:

```
SmartWaste/
├── 01_schema.sql         # Tạo cơ sở dữ liệu SmartWasteDB và 14 bảng quan hệ 3NF
├── 02_sample_data.sql    # Nạp dữ liệu mẫu 8 vai trò, 5 tầng học, 12 thùng rác, người dùng
└── 03_test_queries.sql   # Kịch bản kiểm tra toàn vẹn dữ liệu
```

### Các bước thực hiện:
1. Mở **SQL Server Management Studio (SSMS)**.
2. Kết nối tới SQL Server cục bộ bằng tài khoản quản trị **SQL Server Authentication** (ví dụ: `sa` / mật khẩu `12345` hoặc `123456`).
3. Mở file `01_schema.sql` và bấm **Execute** (hoặc phím `F5`). Kiểm tra thông báo: `Commands completed successfully.`
4. Mở file `02_sample_data.sql` và bấm **Execute** (`F5`) để nạp tài khoản mẫu (toàn bộ tài khoản có mật khẩu mặc định đã băm PBKDF2 là: `123456`).
5. Mở file `03_test_queries.sql` và bấm **Execute** để kiểm tra: đảm bảo tất cả các bảng đều có dữ liệu và khóa ngoại liên kết hợp lệ.

---

## 3. Cấu Hình Kết Nối Cơ Sở Dữ Liệu Trong Mã Nguồn Java

File cấu hình kết nối nằm tại:
`src/java/dao/DBContext.java`

Kiểm tra thông số cấu hình cổng, tài khoản `sa` và mật khẩu cho khớp với máy cá nhân của bạn:

```java
package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    private static final String SERVER_NAME = "localhost";
    private static final String PORT_NUMBER = "1433";
    private static final String DATABASE_NAME = "SmartWasteDB";
    private static final String USER_ID = "sa";       // Tên đăng nhập SQL Server
    private static final String PASSWORD = "12345";   // Mật khẩu SQL Server của máy bạn

    public static Connection getConnection() throws Exception {
        String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT_NUMBER 
                   + ";databaseName=" + DATABASE_NAME;
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, USER_ID, PASSWORD);
    }
}
```

> **Lưu ý:** Thư viện `mssql-jdbc-9.4.1.jre8.jar` hoặc `sqljdbc4.jar` đã được đính kèm sẵn trong thư mục `web/WEB-INF/lib/` của dự án.

---

## 4. Biên Dịch & Triển Khai Backend Java Web (Apache Tomcat 9)

### Cách 1: Chạy từ Apache NetBeans IDE
1. Mở NetBeans IDE, chọn **File** &rarr; **Open Project...** và dẫn tới thư mục `SmartWaste`.
2. Chuột phải vào tên Project `SmartWaste`, chọn **Clean and Build**.
3. Chuột phải vào Project chọn **Run** (phím tắt `F6`). NetBeans sẽ tự động đóng gói file WAR, deploy vào Tomcat và mở trình duyệt tại:
   `http://localhost:8080/SmartWaste/`

### Cách 2: Biên dịch qua Ant và chạy trên Apache Tomcat 9 độc lập
1. Mở PowerShell tại thư mục dự án và thực hiện biên dịch gói WAR:
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_172"
   & "C:\Program Files\NetBeans-13\netbeans\extide\ant\bin\ant.bat" -f build.xml dist
   ```
2. File thành phẩm `SmartWaste.war` được tạo tại thư mục `dist/SmartWaste.war`.
3. Copy file `SmartWaste.war` vào thư mục `webapps` của Tomcat:
   `C:\tomcat\apache-tomcat-9.0.113\webapps\SmartWaste.war`
4. Khởi động Tomcat bằng script:
   `C:\tomcat\apache-tomcat-9.0.113\bin\startup.bat`
5. Truy cập trình duyệt: `http://localhost:8080/SmartWaste/`

---

## 5. Cài Đặt & Nạp Firmware Cho Vi Điều Khiển ESP32 (IoT Hardware Setup)

Khác với mô hình Arduino cũ phải cắm cáp Serial vào máy tính, phiên bản **SmartWaste 2.0** hoạt động độc lập bằng vi điều khiển **ESP32** qua sóng Wi-Fi.

### 5.1. Sơ đồ đấu dây 4 sợi tối giản:
Kết nối mô-đun cảm biến siêu âm HC-SR04 với bo mạch ESP32:

| Chân HC-SR04 | Chân ESP32 NodeMCU | Màu dây gợi ý | Ý nghĩa kỹ thuật |
|:---:|:---:|:---:|---|
| **VCC** | **VIN (hoặc 5V)** | Đỏ | Cấp nguồn 5V nuôi bộ phát siêu âm |
| **GND** | **GND** | Đen | Nối đất chung (Mass) |
| **TRIG**| **GPIO 5 (D5)** | Vàng / Trắng | Kích phát chùm xung siêu âm 10µs |
| **ECHO**| **GPIO 18 (D18)** | Xanh lá | Đón xung phản hồi từ bề mặt rác |

### 5.2. Cài đặt môi trường Arduino IDE cho ESP32:
1. Mở **Arduino IDE** &rarr; Chọn **File** &rarr; **Preferences**.
2. Tại ô **Additional Boards Manager URLs**, dán đường dẫn sau:
   `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
3. Chọn **Tools** &rarr; **Board** &rarr; **Boards Manager...**, tìm kiếm `esp32` của *Espressif Systems* và bấm **Install**.
4. Chọn Bo mạch: **Tools** &rarr; **Board** &rarr; **esp32** &rarr; **ESP32 Dev Module** (hoặc *DOIT ESP32 DEVKIT V1*).
5. Chọn Cổng COM nhận diện khi cắm cáp USB: **Tools** &rarr; **Port** &rarr; `COMx`.

### 5.3. Cấu hình và nạp mã nguồn:
1. Mở file mã nguồn:
   `iot/SmartWaste_ESP32/SmartWaste_ESP32.ino`
2. Cập nhật thông số Wi-Fi và địa chỉ IP máy chủ Tomcat:
   ```cpp
   // Cấu hình Wi-Fi
   const char* WIFI_SSID = "TEN_WIFI_CUA_BAN";
   const char* WIFI_PASS = "MAT_KHAU_WIFI";

   // Cấu hình máy chủ Tomcat (Sử dụng IP LAN nội bộ của máy chủ, kiểm tra bằng ipconfig)
   const char* SERVER_URL = "http://192.168.1.147:8080/SmartWaste/api/bin/update-fill";

   // Mã thùng rác vật lý gắn bo mạch
   const char* BIN_ID = "BIN-001";
   ```
3. Bấm nút **Upload** (Mũi tên sang phải) trên Arduino IDE để nạp code vào ESP32.
4. Mở **Serial Monitor** (Tốc độ `115200 baud`) để theo dõi:
   ```
   [WIFI] Connected! IP: 192.168.1.205
   [TELEMETRY] Measured: 15.2 cm -> Fill: 65%
   [HTTP POST] Response 200: OK - Sensor telemetry recorded for BIN-G-01 | Fill: 65%
   ```

---

## 6. Mở Port Tường Lửa Cho ESP32 Truy Cập Máy Chủ (Windows Firewall)

Để ESP32 có thể gửi gói tin HTTP POST tới Tomcat port 8080 qua mạng Wi-Fi nội bộ, bạn cần mở cổng firewall:

Mở **PowerShell (Run as Administrator)** và chạy lệnh:
```powershell
New-NetFirewallRule -DisplayName "Apache Tomcat 8080 for ESP32" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

---

## 7. Kiểm Tra Hoạt Động Của Hệ Thống (Health Check & Verification)

1. **Trang chủ giới thiệu:** `http://localhost:8080/SmartWaste/`
   - Hiển thị đầy đủ thông tin giới thiệu, các phân hệ và chỉ số khuôn viên FPT HCM.
2. **Trang đăng nhập:** `http://localhost:8080/SmartWaste/login`
   - Đăng nhập tài khoản Super Admin: `superadmin@smartwaste.com` / `123456`.
3. **Bản đồ tương tác thời gian thực:** `http://localhost:8080/SmartWaste/map`
   - Hiển thị 12 điểm thùng rác tại 5 tầng học của Đại học FPT TP.HCM trên bản đồ Leaflet.js.
4. **Kiểm thử API nhận dữ liệu viễn trắc:**
   Trong terminal PowerShell, chạy thử:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8080/SmartWaste/api/bin/update-fill?binID=BIN-001&fillPercent=85" -Method Post
   ```
   Kết quả trả về HTTP 200: `OK - Sensor telemetry recorded for BIN-G-01 | Fill: 85%`.

---

## 8. Bảng Xử Lý Các Sự Cố Thường Gặp (Troubleshooting)

| Sự Cố (Issue) | Nguyên Nhân (Cause) | Hướng Khắc Phục (Solution) |
|---|---|---|
| **SQL Login Failed (Error 18456)** | Sai mật khẩu tài khoản `sa` hoặc chế độ SQL Server Authentication chưa bật | Mở SSMS, chuột phải Server Properties &rarr; Security &rarr; chọn "SQL Server and Windows Authentication mode", đặt lại mật khẩu `sa` và cập nhật trong `DBContext.java`. |
| **Port 8080 Already in Use** | Một tiến trình Tomcat cũ hoặc service khác đang chiếm port 8080 | Chạy lệnh PowerShell: `Get-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess \| Stop-Process -Force`. |
| **ESP32 báo lỗi HTTP Code -1** | ESP32 không tìm thấy máy chủ hoặc bị chặn tường lửa | Đảm bảo laptop và ESP32 bắt chung mạng Wi-Fi; kiểm tra đúng IP máy tính (`ipconfig`); chạy lệnh mở Firewall ở Mục 6. |
| **Lỗi HTTP 404 khi gọi API** | `SensorServlet` bị trùng mapping hoặc thiếu whitelist | Đảm bảo file `web.xml` không chứa mapping thủ công bị trùng; kiểm tra `AuthFilter.java` đã có `/api/bin/update-fill` trong `PUBLIC_PREFIX`. |
