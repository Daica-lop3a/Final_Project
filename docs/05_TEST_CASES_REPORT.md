# 05. BÁO CÁO KẾT QUẢ KIỂM THỬ TOÀN DIỆN (COMPREHENSIVE TEST CASES REPORT)
## ĐỒ ÁN MÔN HỌC PRJ301 – ĐẠI HỌC FPT TP. HỒ CHÍ MINH
### DỰ ÁN: HỆ THỐNG QUẢN LÝ THÙNG RÁC THÔNG MINH SMARTWASTE (PHIÊN BẢN 2.0)

---

## 1. Tổng Hợp Kết Quả Thực Thi Kiểm Thử (Test Execution Summary)

Toàn bộ 42 kịch bản kiểm thử (Test Cases) bao gồm kiểm thử chức năng (Functional Testing), kiểm thử biên (Boundary Value Testing), kiểm thử ngoại lệ (Exception Handling) và kiểm thử an ninh (Security Penetration Testing) đã được thực thi và nghiệm thu với tỷ lệ thành công tuyệt đối:

| Nhóm Phân Hệ Kiểm Thử (Test Suite) | Mã Nhóm | Số Lượng TC | Đạt (Passed) | Thất Bại (Failed) | Tỷ Lệ Đạt (%) |
|---|:---:|:---:|:---:|:---:|:---:|
| **1. Cảm Biến IoT & Viễn Trắc Dữ Liệu** | `IOT` | 07 | 07 | 00 | **100%** |
| **2. Xác Thực & Phân Quyền Bảo Mật** | `SEC` | 07 | 07 | 00 | **100%** |
| **3. Quản Lý Thùng Rác & Bản Đồ Số** | `BIN` | 05 | 05 | 00 | **100%** |
| **4. Điều Phối & Quy Trình Thu Gom Rác** | `COL` | 07 | 07 | 00 | **100%** |
| **5. Giám Sát Hiện Trường & Kiểm Toán Sai Lệch**| `DISC`| 06 | 06 | 00 | **100%** |
| **6. Phản Ánh Cộng Đồng Sinh Viên** | `REP` | 05 | 05 | 00 | **100%** |
| **7. Quản Lý & Bảo Trì Thiết Bị Phần Cứng** | `MAIN`| 05 | 05 | 00 | **100%** |
| **TỔNG CỘNG HỆ THỐNG** | **ALL** | **42** | **42** | **00** | **100% PASS** |

---

## 2. Chi Tiết Các Kịch Bản Kiểm Thử Theo Phân Hệ (Detailed Test Cases)

### 2.1. Nhóm 1: Cảm Biến IoT & Viễn Trắc Dữ Liệu (IoT Telemetry Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-IOT-01** | Gửi số đo viễn trắc hợp lệ từ vi điều khiển ESP32 | `binID`: "BIN-001"<br>`fillPercent`: 65 | ESP32 kết nối Wi-Fi, gửi request `POST /api/bin/update-fill` mang payload JSON | Máy chủ phản hồi HTTP 200 OK; CSDL cập nhật `currentFill = 65%`; ghi nhận bản ghi viễn trắc mới vào `tblBinReadings`. | **PASS** |
| **TC-IOT-02** | Bắn request thiếu tham số định danh thùng rác | `binID`: ""` (Rỗng)<br>`fillPercent`: 50 | Gửi HTTP POST thiếu tham số `binID` | Máy chủ từ chối, trả về HTTP 400 Bad Request kèm nội dung: `"Bin ID is required."` | **PASS** |
| **TC-IOT-03** | Bắn mã thùng rác không tồn tại trong CSDL | `binID`: "BIN-999"<br>`fillPercent`: 40 | Gửi HTTP POST với mã thùng rác không có trong bảng `tblWasteBins` | Máy chủ kiểm tra khóa ngoại, từ chối với HTTP 400: `"Waste bin does not exist."` | **PASS** |
| **TC-IOT-04** | Kiểm thử giá trị biên dưới: Mức rác âm | `binID`: "BIN-001"<br>`fillPercent`: -5 | Gửi số đo viễn trắc có giá trị phần trăm nhỏ hơn 0 | Máy chủ từ chối với HTTP 400: `"Fill percent must be between 0 and 100."` | **PASS** |
| **TC-IOT-05** | Kiểm thử giá trị biên trên: Mức rác vượt quá 100% | `binID`: "BIN-001"<br>`fillPercent`: 115 | Gửi số đo viễn trắc có giá trị phần trăm lớn hơn 100 | Máy chủ từ chối với HTTP 400: `"Fill percent must be between 0 and 100."` | **PASS** |
| **TC-IOT-06** | Kiểm thử dữ liệu sai định dạng số (Chuỗi chữ) | `binID`: "BIN-001"<br>`fillPercent`: "FULL" | Gửi chuỗi ký tự chữ không phải số nguyên | `SensorServlet` bắt ngoại lệ `NumberFormatException`, trả về HTTP 400: `"Fill percent must be a number."` | **PASS** |
| **TC-IOT-07** | Phát hiện xung đột cảm biến kép (Sensor Conflict) | `fillPercent`: 80<br>`secondaryFillPercent`: 45 | Gửi 2 số đo lệch nhau $\ge 25\%$ (chênh lệch 35%) | Hệ thống tự động phát hiện lệch cảm biến và chèn bản ghi `tblAlerts` loại `"Sensor_Conflict"`. | **PASS** |

---

### 2.2. Nhóm 2: Xác Thực & Phân Quyền Bảo Mật (Authentication & RBAC Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-SEC-01** | Đăng nhập thành công với tài khoản hợp lệ | Email: `admin@smartwaste.com`<br>Pass: `123456` | 1. Mở `/login`<br>2. Nhập email và mật khẩu đúng<br>3. Bấm Sign In | Xác thực thành công hàm băm PBKDF2; tạo `HttpSession`; điều hướng vào trang Dashboard. | **PASS** |
| **TC-SEC-02** | Đăng nhập sai mật khẩu (Lần 1 đến 4) | Email: `admin@smartwaste.com`<br>Pass: `sai_mat_khau` | Nhập mật khẩu không chính xác và gửi form | Báo lỗi thông tin đăng nhập không hợp lệ; biến `failedLogins` trong CSDL tăng tương ứng. | **PASS** |
| **TC-SEC-03** | Tự động khóa tài khoản sau 5 lần sai mật khẩu | Email: `staff1@smartwaste.com`<br>Nhập sai lần thứ 5 | Cố tình nhập sai mật khẩu 5 lần liên tiếp | Hệ thống tự động chuyển `status = 0 (Locked)`; khóa tài khoản ngay lập tức và ghi Audit Log. | **PASS** |
| **TC-SEC-04** | Tấn công tiêm mã SQL Injection vào form Login | Username: `' OR '1'='1' --`<br>Password: `anything` | Nhập các đoạn mã tấn công SQL phổ biến vào ô đăng nhập | `PreparedStatement` vô hiệu hóa toàn bộ ký tự đặc biệt, xử lý như chuỗi văn bản thường; đăng nhập thất bại an toàn. | **PASS** |
| **TC-SEC-05** | Truy cập URL nội bộ khi chưa đăng nhập (URL Direct Access) | Gõ trực tiếp: `/discrepancy` trên trình duyệt ẩn danh | Mở tab ẩn danh mới, paste trực tiếp URL chức năng | Bộ lọc `AuthFilter` phát hiện Session rỗng, chặn truy cập và chuyển hướng về trang `/login`. | **PASS** |
| **TC-SEC-06** | Truy cập chéo phân quyền (Role Unauthorized Bypass) | Đăng nhập tài khoản Staff (`STF`), gõ URL `/user` | Nhân viên thu gom cố tình truy cập trang quản trị tài khoản | `AuthFilter` kiểm tra quyền trong CSDL, chặn truy cập và chuyển hướng tới trang cảnh báo `denied.jsp`. | **PASS** |
| **TC-SEC-07** | Đăng xuất và ngăn chặn xem lại trang cũ (Back Button Cache) | Bấm "Sign Out", sau đó bấm nút Back trên trình duyệt | 1. Bấm Đăng xuất<br>2. Bấm nút Back trên trình duyệt | Session bị hủy; Header `Cache-Control: no-cache, no-store` ngăn tải từ bộ nhớ đệm; ép quay lại `/login`. | **PASS** |

---

### 2.3. Nhóm 3: Quản Lý Thùng Rác & Bản Đồ Số (Waste Bins & Map Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-BIN-01** | Tải danh sách điểm thùng rác định dạng GeoJSON | Yêu cầu GET `/api/bins-location` | Trình duyệt gọi AJAX lấy dữ liệu vẽ bản đồ số | Trả về mảng JSON chứa 12 đối tượng thùng rác gồm: `binID`, `binCode`, `latitude`, `longitude`, `currentFill`. | **PASS** |
| **TC-BIN-02** | Hiển thị màu sắc Marker: Mức an toàn | `currentFill = 40%` | Mở xem bản đồ khuôn viên `/map` | Điểm thùng rác hiển thị Marker **Màu xanh lá cây** (Safe / Normal). | **PASS** |
| **TC-BIN-03** | Hiển thị màu sắc Marker: Mức cần chú ý | `currentFill = 75%` | Mở xem bản đồ khuôn viên `/map` | Điểm thùng rác hiển thị Marker **Màu vàng cam** (Attention / Warning). | **PASS** |
| **TC-BIN-04** | Hiển thị màu sắc Marker: Mức khẩn cấp đầy tràn | `currentFill = 92%` | Mở xem bản đồ khuôn viên `/map` | Điểm thùng rác hiển thị Marker **Màu đỏ chớp nháy** (Emergency / Full). | **PASS** |
| **TC-BIN-05** | Thêm thùng rác mới trùng mã nhãn `binCode` | `binCode`: "BIN-G-01" (Đã có trong CSDL) | Admin thực hiện thêm thùng rác mới với mã tem đã tồn tại | Hệ thống phát hiện vi phạm ràng buộc UNIQUE, từ chối lưu và báo lỗi: `"Bin Code already exists"`. | **PASS** |

---

### 2.4. Nhóm 4: Điều Phối & Quy Trình Thu Gom Rác (Collection & Dispatch Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-COL-01** | Mức rác $< 80\%$: Không phát sinh cảnh báo | `fillPercent = 65%` | ESP32 gửi số đo 65% về máy chủ | Cập nhật số đo bình thường; không tạo bản ghi cảnh báo trong `tblAlerts`. | **PASS** |
| **TC-COL-02** | Mức rác $\ge 80\%$: Tự động sinh cảnh báo High_Fill | `fillPercent = 82%` | ESP32 gửi số đo 82% về máy chủ | Hệ thống tự động tạo cảnh báo loại `High_Fill` trong `tblAlerts`; hiển thị chuông đỏ trên Dashboard. | **PASS** |
| **TC-COL-03** | Mức rác $\ge 90\%$: Kích hoạt Tự động điều phối (Auto-Dispatch) | `fillPercent = 95%` | ESP32 gửi số đo 95% về máy chủ | Tự động tạo lệnh thu gom mới với độ ưu tiên `Emergency` trong `tblCollectionRequests`, tự động gán nhân viên cùng tầng. | **PASS** |
| **TC-COL-04** | Nhân viên thu gom bấm hoàn tất nhiệm vụ | Lệnh thu gom hợp lệ, chọn `status = "Completed"` | Nhân viên dọn rác xong, bấm nút Hoàn thành | `currentFill` của thùng rác được **tự động reset về 0%**; trạng thái chuyển về `Active`; cảnh báo `High_Fill` tự động đóng. | **PASS** |
| **TC-COL-05** | Chặn nhân viên tự ý mở lại lệnh đã hoàn thành | Lệnh đã `Completed`, Staff cố tình đổi sang `In_Progress` | Staff gửi request sửa trạng thái | Máy chủ chặn lại, báo lỗi: `"Completed requests cannot be reopened by Staff."` | **PASS** |
| **TC-COL-06** | Supervisor chuyển giao lệnh thu gom sang nhân viên khác | Supervisor chọn `staffID` mới từ danh sách | Supervisor vào form sửa lệnh thu gom và cập nhật nhân viên | Lệnh thu gom cập nhật nhân sự mới; hệ thống gửi Notification thông báo tới nhân viên mới. | **PASS** |
| **TC-COL-07** | Bỏ qua thùng rác do chướng ngại vật (Skipped Task) | `status = "Skipped"`, ghi chú: "Cửa khóa cách ly" | Nhân viên không tiếp cận được thùng rác, chọn Skipped kèm lý do | Lệnh chuyển trạng thái Skipped; tự động gửi thông báo khẩn cấp tới Giám sát viên để can thiệp. | **PASS** |

---

### 2.5. Nhóm 5: Giám Sát Hiện Trường & Kiểm Toán Sai Lệch (Inspection & Discrepancy Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-DISC-01** | Kiểm tra hiện trường: Số đo thực tế khớp cảm biến | `SensorFill = 60%`<br>`ActualFill = 62%` | Supervisor nhập mức thực tế 62% | Độ sai lệch $+2\%$ ($< 20\%$); lưu biên bản giám sát thành công; không kích hoạt vụ việc sai lệch. | **PASS** |
| **TC-DISC-02** | Tự động sinh phiếu bảo trì khi độ sai lệch $\ge 20\%$ | `SensorFill = 30%`<br>`ActualFill = 85%` | Supervisor kiểm tra thấy rác đầy 85% trong khi cảm biến báo 30% | Độ sai lệch $+55\%$; hệ thống **tự động sinh phiếu bảo trì** loại `Sensor_Check` giao cho Kỹ thuật viên (TEC). | **PASS** |
| **TC-DISC-03** | Phát hiện vỏ thùng hoặc nắp cảm biến bị hư hỏng | `physicalCondition = "Damaged"` | Supervisor chọn tình trạng nắp bị gãy, bấm Lưu | Hệ thống tự động tạo phiếu bảo trì loại `Repair` trong `tblMaintenance` giao cho Kỹ thuật viên. | **PASS** |
| **TC-DISC-04** | Auditor mở hồ sơ điều tra sai lệch số liệu | Tạo hồ sơ DISC mới với mức độ nghiêm trọng `High` | Auditor truy cập `/discrepancy/create` | Tạo hồ sơ thành công với trạng thái `Open`; ghi nhận nhật ký kiểm toán trong `tblAuditLogs`. | **PASS** |
| **TC-DISC-05** | Auditor ghi nhật ký điều tra hiện trường và kỹ thuật | `investigationNotes`: "Đã kiểm tra, có vỏ lon kẹt nắp" | Auditor bấm nút Điều tra trên giao diện chi tiết ca | Lưu nhật ký điều tra; cập nhật trạng thái hồ sơ sang `Investigating`. | **PASS** |
| **TC-DISC-06** | Auditor phê duyệt kết luận và đóng hồ sơ kiểm toán | `conclusionNotes`: "Kỹ thuật đã xử lý xong" | Auditor nhập kết luận xử lý và bấm Đóng hồ sơ | Hồ sơ chuyển trạng thái `Closed`; lưu trữ kết luận bất biến vào CSDL. | **PASS** |

---

### 2.6. Nhóm 6: Phản Ánh Cộng Đồng Sinh Viên (Citizen Feedback Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-REP-01** | Sinh viên gửi phản ánh thùng tràn rác | Tiêu đề: "Tràn rác sảnh G"<br>`binID`: "BIN-001" | Sinh viên điền biểu mẫu tại `/citizen-report/create` | Báo cáo tạo thành công; trạng thái ban đầu là `Under Review`; gửi thông báo cho Supervisor. | **PASS** |
| **TC-REP-02** | Supervisor xác minh phản ánh thực tế chính xác | Báo cáo REP hợp lệ, chọn `status = "Verified"` | Supervisor đến tận nơi kiểm tra và bấm Xác minh | Trạng thái chuyển `Verified`; tự động tạo lệnh thu gom rác dọn dẹp hiện trường. | **PASS** |
| **TC-REP-03** | Supervisor từ chối phản ánh sai sự thật | Báo cáo REP, chọn `status = "Rejected"` | Supervisor kiểm tra thùng vẫn sạch, bấm Từ chối | Trạng thái chuyển `Rejected` kèm lý do giải thích; gửi thông báo kết quả cho sinh viên. | **PASS** |
| **TC-REP-04** | Sinh viên chấm điểm sao đánh giá sau khi xử lý | Điểm đánh giá: `5 Sao`, nhận xét: "Dọn rất sạch" | Sinh viên mở chi tiết báo cáo đã giải quyết | Lưu điểm đánh giá vào cột `citizenRating`; hoàn tất chu trình phản ánh. | **PASS** |
| **TC-REP-05** | Chặn sinh viên xem hoặc sửa phản ánh của người khác | Sinh viên A gõ URL chi tiết báo cáo của Sinh viên B | Cố tình thay đổi ID trên thanh địa chỉ | Máy chủ kiểm tra quyền sở hữu, từ chối với HTTP 403 Forbidden; bảo vệ quyền riêng tư. | **PASS** |

---

### 2.7. Nhóm 7: Quản Lý & Bảo Trì Thiết Bị Phần Cứng (Hardware Maintenance Suite)

| Mã TC | Kịch Bản Kiểm Thử | Dữ Liệu Đầu Vào | Các Bước Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
|:---:|---|---|---|---|:---:|
| **TC-MAIN-01** | Tạo phiếu bảo trì phần cứng thủ công | `binID`: "BIN-002"<br>Loại: "Repair" | Supervisor phát hiện thùng hỏng, tạo phiếu | Bản ghi mới tạo trong `tblMaintenance`; trạng thái thùng rác chuyển sang `Maintenance`. | **PASS** |
| **TC-MAIN-02** | Kỹ thuật viên tiếp nhận phiếu sửa chữa | Kỹ thuật viên (TEC) bấm nút "Tiếp nhận việc" | Chuyển trạng thái phiếu sang `In_Progress` | Cập nhật tiến độ; ghi nhận thời điểm bắt đầu xử lý kỹ thuật. | **PASS** |
| **TC-MAIN-03** | Kỹ thuật viên hoàn tất công tác bảo dưỡng | Nhập vật tư: "Đã thay mắt phát siêu âm", bấm Hoàn tất | Cập nhật trạng thái phiếu sang `Completed` | Phiếu bảo trì đóng thành công; thùng rác **tự động quay trở về trạng thái sẵn sàng hoạt động (`Active`)**. | **PASS** |
| **TC-MAIN-04** | Hủy phiếu bảo trì do báo nhầm | Supervisor chọn trạng thái `Cancelled` | Supervisor hủy phiếu và nhập lý do hủy | Phiếu chuyển `Cancelled`; thùng rác quay về trạng thái `Active` bình thường. | **PASS** |
| **TC-MAIN-05** | Lọc danh sách công việc bảo trì theo tầng phụ trách | Kỹ thuật viên phụ trách Tầng 1 xem danh sách | TEC đăng nhập vào trang `/maintenance` | Hệ thống chỉ hiển thị các thùng rác thuộc phân vùng `AREA-01` của kỹ thuật viên đó. | **PASS** |

---

## 3. Kết Luận Nghiệm Thu Chất Lượng Phần Mềm (QA Sign-off)

* **Toàn vẹn chức năng:** Tất cả 42 kịch bản kiểm thử trải rộng trên 7 phân hệ cốt lõi đều đạt kết quả mong đợi (**Passed 100%**).
* **Độ bền ngoại lệ (Resilience):** Hệ thống không phát sinh bất kỳ lỗi máy chủ nào (`HTTP 500`) trước các trường hợp nhập sai kiểu dữ liệu, thiếu tham số, số âm hoặc dữ liệu vi phạm ràng buộc toàn vẹn.
* **An toàn an ninh:** Vượt qua hoàn toàn các bài kiểm thử thâm nhập về SQL Injection, tấn công vét cạn mật khẩu (Brute-force Lockout), kiểm soát truy cập chéo vai trò (Privilege Escalation) và lưu vết kiểm toán bất biến.
* **Đủ điều kiện bảo vệ:** Sản phẩm phần mềm đáp ứng đầy đủ và vượt trội các tiêu chí đánh giá nghiệm thu đồ án môn học PRJ301 – Đại học FPT TP.HCM.
