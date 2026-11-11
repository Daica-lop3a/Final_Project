# 02. ĐẶC TẢ YÊU CẦU NGHIỆP VỤ & PHÂN QUYỀN VAI TRÒ (ROLE-BASED FUNCTIONAL SPECIFICATION)
## ĐỒ ÁN MÔN HỌC PRJ301 – ĐẠI HỌC FPT TP. HỒ CHÍ MINH
### HỆ THỐNG QUẢN LÝ THÙNG RÁC THÔNG MINH SMARTWASTE (PHIÊN BẢN 2.0)

---

## 1. Danh Mục Tài Khoản Khởi Tạo Mẫu (Verified Seed Accounts)

Toàn bộ tài khoản khởi tạo mẫu trong cơ sở dữ liệu đều có mật khẩu mặc định là: **`123456`** (đã được băm an toàn bằng thuật toán `PBKDF2WithHmacSHA256` với 20.000 vòng lặp):

| Mã Vai Trò | Tên Nhóm Vai Trò | Email Đăng Nhập | Mật Khẩu | Phạm Vi Trách Nhiệm Nghiệp Vụ Chính |
|:---:|---|---|:---:|---|
| **`SAD`** | **Super Administrator** (Quản Trị Tối Cao) | `superadmin@smartwaste.com` | `123456` | Toàn quyền kiểm soát hệ thống, tham số vận hành, sao lưu CSDL, phê duyệt mật khẩu Admin và giám sát Audit Logs. |
| **`ADM`** | **System Administrator** (Quản Trị Hệ Thống) | `admin@smartwaste.com` | `123456` | Quản lý người dùng, phân công khu vực, quản lý danh mục thùng rác (CRUD), phân vùng 5 tầng học và danh mục thiết bị IoT. |
| **`MGR`** | **Operations Manager** (Quản Lý Vận Hành) | `manager@smartwaste.com` | `123456` | Giám sát điều phối thu gom đa vùng, phê duyệt kế hoạch bảo trì, xem thống kê KPIs, xuất báo cáo tổng hợp. |
| **`SUP`** | **Area Supervisor** (Giám Sát Viên Khu Vực) | `supervisor@smartwaste.com` | `123456` | Điều phối lệnh thu gom theo tầng, kiểm tra thực địa thùng rác (Inspection), phát hiện sai lệch và xác minh phản ánh của sinh viên. |
| **`STF`** | **Collection Staff** (Nhân Viên Thu Gom) | `staff1@smartwaste.com` | `123456` | Tiếp nhận và thực hiện lệnh thu gom rác tại các tầng, bấm hoàn tất lệnh thu gom (hệ thống tự reset mức rác về 0%). |
| **`TEC`** | **IoT Technician** (Kỹ Thuật Viên Phần Cứng) | `tech@smartwaste.com` | `123456` | Tiếp nhận phiếu bảo trì, hiệu chuẩn vi điều khiển ESP32, lau mắt cảm biến siêu âm HC-SR04, cập nhật vật tư sửa chữa. |
| **`AUD`** | **System Auditor** (Kiểm Toán Viên Hệ Thống) | `auditor@smartwaste.com` | `123456` | Giám sát chất lượng dữ liệu, đối soát sai lệch giữa cảm biến và thực tế (Discrepancy Cases), truy vết Audit Trail bất biến. |
| **`USR`** | **Campus Citizen** (Sinh Viên & Giảng Viên) | `citizen1@smartwaste.com` | `123456` | Tìm thùng rác trên bản đồ số, gửi phản ánh rác tràn kèm hình ảnh và đánh giá sao chất lượng sau khi được dọn dẹp. |

---

## 2. Đặc Tả Chi Tiết Chức Năng Của Từng Nhóm Vai Trò

### 2.1. Super Administrator (`SAD` - Quản Trị Viên Cấp Cao)
* **Master Governance:** Có quyền truy cập không giới hạn vào mọi phân hệ của hệ thống.
* **Quản trị phân quyền động (`/role`, `/role/*`):** Xem và gán danh mục quyền hạn chi tiết cho từng vai trò trong `tblRolePermissions`.
* **Phê duyệt đặt lại mật khẩu Admin (`/admin/password-approvals`):** Xử lý các yêu cầu cấp lại mật khẩu khẩn cấp từ các Admin cấp dưới.
* **Cấu hình tham số hệ thống (`/system-config`):** Điều chỉnh ngưỡng kích hoạt cảnh báo rác tràn (`HIGH_FILL_THRESHOLD = 80%`), ngưỡng tự động sinh lệnh thu gom (`AUTO_DISPATCH_THRESHOLD = 90%`), số lần đăng nhập sai tối đa trước khi khóa tài khoản (`MAX_FAILED_LOGINS = 5`).
* **Sao lưu dữ liệu thảm họa (`/system/backup`):** Xuất toàn bộ dữ liệu máy chủ ra file script SQL phục vụ công tác khôi phục dữ liệu (Disaster Recovery).
* **Kiểm toán an ninh tối cao (`/audit-log`):** Truy xuất toàn bộ nhật ký truy cập, IP máy khách và lịch sử tác động dữ liệu của mọi thành viên.

### 2.2. System Administrator (`ADM` - Quản Trị Hệ Thống)
* **Quản lý người dùng (`/user`, `/user/*`):** Thêm mới tài khoản nhân sự, chỉ định vai trò, gán tầng học phụ trách, khóa hoặc mở khóa tài khoản người dùng vi phạm.
* **Quản lý hạ tầng thùng rác (`/bin`, `/bin/*`):** Đăng ký mã thùng rác vật lý (`binCode`), mô tả vị trí chi tiết, gán tọa độ GPS (kinh độ, vĩ độ) và dung tích thùng (Lít).
* **Quản lý 5 tầng học (`/area`, `/area/*`):** Cấu hình các phân vùng từ `AREA-00` (Tầng G) đến `AREA-04` (Tầng 4) bám sát tòa nhà Trống Đồng FPT HCM.
* **Quản lý thiết bị cảm biến ngoại vi (`/device`, `/device/*`):** Gán mã vi điều khiển ESP32 với thùng rác, theo dõi tình trạng pin và nhịp tim kết nối (Heartbeat ping).
* **Quản lý danh mục phân loại (`/catalog`, `/catalog/*`):** Định nghĩa danh mục trạng thái thùng, loại rác (Tái chế, Hữu cơ, Vô cơ) và loại thiết bị.

### 2.3. Operations Manager (`MGR` - Quản Lý Vận Hành)
* **Giám sát thời gian thực:** Quan sát Dashboard trực quan tổng thể toàn bộ 5 tầng học của trường.
* **Điều phối đa tầng:** Can thiệp phân công nhân viên thu gom giữa các tầng học khi có sự kiện đông người (Lễ tốt nghiệp, Hội thảo tại Academic Hall Tầng 4).
* **Phân tích số liệu & Báo cáo (`/report`, `/export`):** Thống kê lượng rác phát sinh theo ngày/tuần/tháng, đánh giá hiệu suất dọn dẹp đúng hạn và xuất dữ liệu ra định dạng Excel/CSV.

### 2.4. Area Supervisor (`SUP` - Giám Sát Viên Tầng Học)
* **Điều phối thu gom tầng phụ trách (`/collection`, `/collection/*`):** Tiếp nhận thông báo thùng rác quá tải, phân công trực tiếp cho nhân viên thu gom (STF) thuộc tầng của mình.
* **Kiểm tra thực địa định kỳ (`/inspection`, `/inspection/*`):** Đi tuần tra, mở form nhập mức rác thực tế mắt thấy (`actualFillPercent`) và tình trạng thùng rác (`physicalCondition`).
  * Nếu mức lệch so với cảm biến $\ge 20\%$: Hệ thống tự động kích hoạt tạo phiếu kiểm tra kỹ thuật cho Technician (TEC).
* **Xác minh phản ánh của sinh viên (`/citizen-report/verify`):** Kiểm tra thực địa khi sinh viên báo cáo thùng rác hỏng/tràn, phê duyệt `Verified` để sinh lệnh dọn rác hoặc `Rejected` nếu báo cáo sai sự thật.

### 2.5. Collection Staff (`STF` - Nhân Viên Thu Gom)
* **Tiếp nhận nhiệm vụ cá nhân:** Xem danh sách lệnh thu gom được phân công trên giao diện điện thoại (`/collection`).
* **Cập nhật tiến độ thu gom:** Nhấn nút **Bắt đầu** (chuyển trạng thái `In_Progress`) khi di chuyển tới vị trí thùng rác.
* **Hoàn tất thu gom:** Thu gom rác, quét mã QR trên thùng rác và nhấn **Hoàn thành** (`Completed`).
  * **Hành vi tự động:** Hệ thống tự động đặt lại `currentFill = 0%`, cập nhật trạng thái thùng về `Active` và tự động đóng cảnh báo `High_Fill` liên quan.

### 2.6. IoT Technician (`TEC` - Kỹ Thuật Viên Phần Cứng)
* **Tiếp nhận phiếu bảo trì (`/maintenance`, `/maintenance/*`):** Nhận các phiếu yêu cầu sửa chữa phần cứng phát sinh từ hệ thống hoặc do Supervisor tạo ra.
* **Kiểm tra & Hiệu chuẩn thiết bị:** Vệ sinh đầu thu phát siêu âm HC-SR04, kiểm tra dây nối 5V/GND/GPIO5/GPIO18, nạp lại Firmware ESP32 nếu cần.
* **Đóng phiếu bảo trì:** Nhập ghi chú kỹ thuật, linh kiện thay thế và bấm hoàn tất. Hệ thống tự động đưa thùng rác về trạng thái sẵn sàng hoạt động (`Active`).

### 2.7. System Auditor (`AUD` - Kiểm Toán Viên Hệ Thống)
* **Giám sát chất lượng dữ liệu (`/data-quality`):** Quét phát hiện các cảm biến bị kẹt số liệu (Stuck Sensor) hoặc các số đo bất thường.
* **Điều tra sai lệch số liệu (`/discrepancy`, `/discrepancy/*`):** Mở hồ sơ điều tra chuyên sâu các ca chênh lệch $\ge 20\%$ giữa mắt thấy và cảm biến báo về.
* **Đối chiếu chứng cứ:** Kiểm tra chuỗi lịch sử viễn trắc trong bảng `tblBinReadings`, ghi nhận biên bản điều tra và phê duyệt đóng hồ sơ (`Closed`).
* **Truy vết an ninh bất biến (`/audit-log`):** Toàn quyền kiểm tra nhật ký hệ thống mà không ai có thể can thiệp sửa xóa.

### 2.8. Campus Citizen (`USR` - Sinh Viên, Cán Bộ Giảng Viên)
* **Bản đồ trực quan (`/map`):** Xem vị trí và mức đầy của các thùng rác xung quanh để chọn thùng rác còn trống gần nhất.
* **Gửi phản ánh (`/citizen-report/create`):** Chụp ảnh hiện trường thùng rác tràn hoặc hỏng nắp gửi về Ban Quản trị cơ sở vật chất.
* **Theo dõi & Đánh giá chất lượng:** Theo dõi tiến độ dọn dẹp và đánh giá chất lượng phục vụ từ 1 đến 5 sao sau khi hoàn thành.

---

## 3. Ma Trận Phân Quyền Chi Tiết Giữa Các Phân Hệ (RBAC Matrix)

| Phân Hệ / Chức Năng | Đường Dẫn (Route) | `SAD` | `ADM` | `MGR` | `SUP` | `STF` | `TEC` | `AUD` | `USR` |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Dashboard Tổng Quan** | `/dashboard`, `/home` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Bản Đồ Số Khuôn Viên** | `/map`, `/api/bins-location` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Hồ Sơ Cá Nhân & Đổi Pass** | `/profile` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Xem Danh Sách Thùng Rác** | `/bin` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Xem Chi Tiết 1 Thùng Rác** | `/bin/detail` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Thêm / Sửa Thùng Rác** | `/bin/create`, `/bin/edit`, `/bin/save` | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Xóa Thùng Rác** | `/bin/delete` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Quản Lý 5 Tầng Học** | `/area`, `/area/*` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Xem Lệnh Thu Gom** | `/collection` | ✅ | ✅ | ✅ | ✅ | ✅ (Vùng) | ❌ | ✅ | ❌ |
| **Phân Công Lệnh Thu Gom** | `/collection/create`, `/collection/save` | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Bắt Đầu / Hoàn Tất Thu Gom** | `/collection/start`, `/collection/complete`| ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Xem Phiếu Bảo Trì** | `/maintenance` | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ (Vùng) | ✅ | ❌ |
| **Tạo Phiếu Bảo Trì** | `/maintenance/create`, `/maintenance/save` | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Xử Lý & Đóng Bảo Trì** | `/maintenance/complete` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **Kiểm Tra Hiện Trường (Inspection)**| `/inspection`, `/inspection/create` | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| **Điều Tra Sai Lệch (Discrepancy)** | `/discrepancy`, `/discrepancy/*` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Kiểm Tra Chất Lượng Dữ Liệu** | `/data-quality` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Nhật Ký Kiểm Toán Bất Biến** | `/audit-log` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Quản Trị Người Dùng** | `/user`, `/user/*` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Phê Duyệt Reset Pass Admin** | `/admin/password-approvals` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Sao Lưu CSDL (Backup)** | `/system/backup` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Cấu Hình Tham Số Ngưỡng** | `/system-config` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Gửi Phản Ánh Sinh Viên** | `/citizen-report/create` | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| **Xác Minh Phản Ánh Sinh Viên**| `/citizen-report/verify` | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Chấm Điểm Đánh Giá Xử Lý** | `/citizen-report/rate` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **API Cảm Biến IoT Telemetry** | `/api/bin/update-fill` | 🟢 **Public Whitelist** (Dành riêng cho ESP32 tự động gửi) |
