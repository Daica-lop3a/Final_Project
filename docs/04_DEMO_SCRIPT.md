# 04. KỊCH BẢN BẢO VỆ ĐỒ ÁN MẪU (STEP-BY-STEP DEFENSE DEMO SCRIPT)
## ĐỒ ÁN MÔN HỌC PRJ301 – ĐẠI HỌC FPT TP. HỒ CHÍ MINH
### THỜI LƯỢNG THUYẾT MINH KHUYẾN NGHỊ: 5 – 7 PHÚT

Kịch bản này được thiết kế theo chuẩn chấm điểm của Hội đồng phản biện môn **PRJ301 (Java Web Application Development)**, làm nổi bật tính ứng dụng thực tế, kiến trúc phân tầng doanh nghiệp (Enterprise 3-Tier), an toàn bảo mật và khả năng tích hợp thiết bị IoT vi điều khiển không dây.

---

## 🎯 Danh Sách Chuẩn Bị Trước Giờ Báo Cáo (Pre-Demo Checklist)

- [ ] Máy chủ **Apache Tomcat 9** đang chạy ổn định tại cổng 8080.
- [ ] Dịch vụ **MS SQL Server** đang chạy với cơ sở dữ liệu `SmartWasteDB` đã nạp dữ liệu.
- [ ] Cửa sổ trình duyệt mở sẵn tại địa chỉ: `http://localhost:8080/SmartWaste/`.
- [ ] Cửa sổ dòng lệnh **PowerShell** mở sẵn để sẵn sàng bắn lệnh viễn trắc IoT (nếu không cắm trực tiếp mạch ESP32).
- [ ] Mạch **ESP32** đã nạp code `SmartWaste_ESP32.ino`, nối sẵn cảm biến siêu âm HC-SR04 và cắm sạc dự phòng/cáp nguồn (nếu trình diễn phần cứng trực tiếp).

---

## 🎬 Kịch Bản Diễn Trình Chi Tiết Từng Phút (Walkthrough Script)

### Phần 1: Giới Thiệu Đề Tài & Kiến Trúc Hệ Thống (Thời lượng: 1 Phút)
1. **Mở trang chủ (Landing Page):** Truy cập `http://localhost:8080/SmartWaste/`.
2. **Thuyết minh với Hội đồng:**
   > *"Kính thưa Thầy/Cô Hội đồng phản biện, đề tài của nhóm chúng em là **Hệ thống Quản lý Thùng rác Thông minh SmartWaste** triển khai cho khuôn viên 5 tầng của tòa nhà Trống Đồng Đại học FPT TP.HCM.*  
   > *Hệ thống được phát triển theo mô hình **Java Web Enterprise 3-Tier MVC**, tầng Controller gồm 27 Servlet độc lập, kết nối Microsoft SQL Server qua `PreparedStatement` chống triệt để SQL Injection, và đặc biệt kết hợp với vi điều khiển **ESP32** gửi số liệu mức rác không dây qua HTTP REST API."*
3. **Mở Bản đồ số khuôn viên:** Bấm vào nút **Explore Live Map** (hoặc truy cập `/map`).
   - Phóng to vào bản đồ số hóa Đại học FPT TP.HCM: Cho thấy **12 điểm thùng rác** trải đều từ Tầng G đến Tầng 4.
   - Bấm vào một thùng rác: Hiển thị Popup vị trí, dung tích 120L, mức đầy hiện tại và màu sắc phân loại (*Xanh: An toàn, Vàng: Cần chú ý, Đỏ: Khẩn cấp*).

---

### Phần 2: Quản Trị Hệ Thống & Nhật Ký An Ninh Bất Biến (Thời lượng: 1 Phút)
1. **Đăng nhập vai trò Super Admin (`SAD`):**
   - Truy cập `/login`.
   - Nhập: **Email:** `superadmin@smartwaste.com` | **Mật khẩu:** `123456`.
   - Hệ thống chuyển hướng mượt mà vào `/dashboard`.
2. **Chứng minh An ninh & Kiểm toán (`/audit-log`):**
   - Bấm vào menu **Governance** &rarr; **Security Audit Logs**.
   - **Chỉ ra cho Thầy/Cô thấy:** Hành động đăng nhập vừa thực hiện lập tức được ghi nhận vào bảng `tblAuditLogs` kèm theo địa chỉ IP máy khách (`request.getRemoteAddr()`) và dấu thời gian chính xác tới từng giây.
   - **Nhấn mạnh:** Bảng này có cơ chế **bất biến (Immutable)**, chỉ cho phép đọc và chèn, không cho phép sửa xóa để phục vụ thanh tra.
3. **Cấu hình tham số vận hành (`/system-config`):**
   - Chỉ ra các tham số động: `AUTO_DISPATCH_THRESHOLD = 90%`, `HIGH_FILL_THRESHOLD = 80%`, `MAX_FAILED_LOGINS = 5`.

---

### Phần 3: Điểm Nhấn Công Nghệ - Viễn Trắc IoT & Tự Động Điều Phối (Thời lượng: 1.5 Phút)
*(Đây là phần ấn tượng nhất để lấy điểm tối đa)*

1. **Chuẩn bị hiện trường:**
   - Mở sẵn màn hình chi tiết thùng rác `BIN-001` (Sảnh Trống Đồng) tại địa chỉ:  
     `http://localhost:8080/SmartWaste/bin/detail?id=BIN-001`.
   - Giữ nguyên tab này trên màn hình trình chiếu.
2. **Kích hoạt dữ liệu cảm biến:**
   - **Cách 1 (Có mạch ESP32):** Dùng tay chắn sát nắp cảm biến siêu âm HC-SR04. ESP32 tự động tính toán mức rác vượt quá 90% và bắn HTTP POST lên máy chủ qua Wi-Fi.
   - **Cách 2 (Mô phỏng qua terminal):** Mở PowerShell chạy lệnh bắn viễn trắc rác đầy 92%:
     ```powershell
     Invoke-WebRequest -Uri "http://localhost:8080/SmartWaste/api/bin/update-fill?binID=BIN-001&fillPercent=92" -Method Post
     ```
     Phản hồi từ Servlet: `OK - Sensor telemetry recorded for BIN-G-01 | Fill: 92%`.
3. **Quan sát trực quan không cần tải lại trang (Zero-Reload Live Sync):**
   - Nhìn vào màn hình trình duyệt: Cơ chế JavaScript Polling tự động phát hiện số đo mới.
   - Đồng hồ đo chuyển từ màu xanh sang **Màu đỏ khẩn cấp (92% - CRITICAL)**.
   - Bảng lịch sử đo đạc ghi nhận ngay dòng viễn trắc mới ở đầu danh sách.
4. **Kiểm tra nghiệp vụ tự động (Automated Business Logic):**
   - Mở mục **Cảnh báo (`/alert`):** Hệ thống đã tự động kích hoạt bản ghi cảnh báo `High_Fill` chuông đỏ.
   - Mở mục **Lệnh thu gom (`/collection`):** Hệ thống đã **tự động tạo ngay một lệnh thu gom khẩn cấp (`Emergency`)** và gán tự động cho nhân viên thu gom phụ trách Tầng G (`staff1`).

---

### Phần 4: Nghiệp Vụ Giám Sát Hiện Trường & Kiểm Toán Sai Lệch (Thời lượng: 1.5 Phút)
*(Giải quyết bài toán cảm biến bị kẹt hoặc báo ảo)*

1. **Đăng nhập vai trò Giám Sát Viên (`SUP`):**
   - Đăng xuất Super Admin &rarr; Đăng nhập: `supervisor@smartwaste.com` / `123456`.
2. **Tạo biên bản kiểm tra thực địa (`/inspection/create`):**
   - Giám sát viên đi tuần tra tại thùng rác `BIN-001`.
   - Màn hình tự nạp số đo cảm biến đang báo: `92%`.
   - Giám sát viên nhìn mắt thực tế trong lòng thùng rác chỉ mới có vài tờ giấy, nhập mức thực tế: `actualFillPercent = 20%`.
   - Độ chênh lệch: $|20\% - 92\%| = 72\% \ge 20\%$. Bấm **Lưu biên bản**.
3. **Kết quả kích hoạt tự động:**
   - Hệ thống tự động phát hiện sai lệch nghiêm trọng.
   - Tự động sinh ngay một hồ sơ sai lệch tại **`tblDiscrepancies`**.
   - Tự động sinh ngay một phiếu bảo trì **`tblMaintenance`** loại `Sensor_Check` giao cho Kỹ thuật viên (TEC) đi lau chùi cảm biến.
4. **Đăng nhập vai trò Kiểm toán viên (`AUD`):**
   - Đăng nhập: `auditor@smartwaste.com` / `123456`.
   - Mở `/discrepancy`: Thấy ca sự cố vừa phát sinh. Auditor đối soát dòng viễn trắc, ghi kết luận *"Đầu cảm biến bám bụi bẩn, đã hiệu chuẩn"* và bấm **Đóng hồ sơ (`Closed`)**.

---

### Phần 5: Nhân Viên Thu Gom Dọn Rác & Khép Kín Vòng Đời (Thời lượng: 1 Phút)
1. **Đăng nhập vai trò Nhân viên Thu gom (`STF`):**
   - Đăng nhập: `staff1@smartwaste.com` / `123456`.
   - Vào mục **Lệnh thu gom (`/collection`)**: Nhân viên chỉ nhìn thấy công việc được giao của riêng mình tại Tầng G.
2. **Thực hiện nhiệm vụ:**
   - Bấm **Bắt đầu** &rarr; Chuyển sang trạng thái `In_Progress`.
   - Dọn sạch rác trong thùng, quét mã QR trên thùng rác và bấm **Hoàn thành (`Completed`)**.
3. **Chứng minh tự động cập nhật:**
   - Mở lại trang bản đồ `/map` hoặc chi tiết thùng `BIN-001`: Mức rác đã được **tự động reset về 0%**, trạng thái trở về **Màu xanh an toàn (`Active`)**, và cảnh báo `High_Fill` được tự động đóng lại.

---

### Phần 6: Phản Ánh Sinh Viên & Kiểm Tra Bảo Mật (Thời lượng: 1 Phút)
1. **Kênh phản ánh cộng đồng (`USR`):**
   - Đăng nhập `citizen1@smartwaste.com` / `123456`.
   - Gửi phản ánh kèm hình ảnh thùng rác tại `/citizen-report/create`.
   - Cho thấy quy trình từ tiếp nhận &rarr; Giám sát viên xác minh &rarr; Sinh viên chấm 5 sao chất lượng.
2. **Khảo nghiệm an ninh phòng thủ (Security Defense):**
   - **Test Chống SQL Injection:** Nhập payload `' OR '1'='1' --` vào ô đăng nhập. Hệ thống xử lý an toàn qua `PreparedStatement`, báo lỗi sai mật khẩu bình thường mà không bị vượt qua.
   - **Test Chống Back Button:** Sau khi bấm Đăng xuất, nhấn nút **Back** trên trình duyệt. Bộ lọc `AuthFilter` lập tức chặn lại và bắt buộc quay lại trang `/login` vì cơ chế `no-store, no-cache`.

---

## 🏆 Câu Kết Luận Kết Thúc Buổi Báo Cáo
> *"Kính thưa Thầy/Cô, hệ thống SmartWaste Version 2.0 đã khép kín toàn bộ chu trình từ phần cứng IoT thu thập số liệu, điều phối tự động, giám sát thực địa, kiểm toán dữ liệu cho đến an ninh bảo mật nhiều lớp. Toàn bộ 42 kịch bản kiểm thử đều đạt 100% kết quả Pass. Nhóm chúng em xin chân thành cảm ơn Thầy/Cô và rất mong nhận được câu hỏi cũng như đóng góp quý báu từ Hội đồng!"*
