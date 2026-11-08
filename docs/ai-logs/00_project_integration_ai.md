# Nhật ký AI: Tích hợp Mã Nguồn Web Cũ CafeQR & Cấu Trúc Dự Án (Y1)

> **Môn học:** SOF309 - Kiểm thử nâng cao cùng AI  
> **Sinh viên thực hiện:** Mai Thế Hải - TS03134  
> **Ngày thực hiện:** 08/11/2026  
> **Giai đoạn:** Tuần 1 - Yêu cầu Y1 (Assignment)

---

## 1. Ngữ cảnh & Mục tiêu
- **Mục tiêu:** Tích hợp toàn bộ mã nguồn của dự án Web cá nhân từ kỳ trước (**capheQR-main**) vào repository đồ án kiểm thử **SOF309-MaiTheHai-TS03134**.
- **Yêu cầu chi tiết:**
  - Clone / Copy toàn bộ mã nguồn Java vào `src/main/java/`, tổ chức thư mục theo từng phân lớp kiến trúc (`controller`, `dao`, `entity`, `filter`, `listener`, `utils`, `META-INF`).
  - Thay thế mọi file có sẵn/mặc định trong thư mục đích bằng mã nguồn của sinh viên (dọn dẹp file `.gitkeep`).
  - Đồng bộ toàn bộ tài nguyên giao diện người dùng vào `src/main/webapp/` (JSP, CSS, JS, hình ảnh, `WEB-INF/web.xml`).
  - Lưu trữ cơ sở dữ liệu `database_postgres.sql` phục vụ kết nối dữ liệu.
  - Cập nhật file cấu hình [pom.xml](../../pom.xml) để bổ sung đầy đủ thư viện của dự án Web (Hibernate 6.5, HikariCP, PostgreSQL Driver, Jakarta Servlet 6.1, JSTL 3.0) song song với khung kiểm thử JUnit 5 và Selenium.
  - Ghi nhật ký minh chứng sử dụng AI theo đúng quy định tại thư mục [docs/ai-logs/](README.md) để phục vụ chấm điểm A (Y6).

---

## 2. Các câu lệnh đã gửi cho AI (Prompt)

### Prompt 1: Yêu cầu đồng bộ mã nguồn CafeQR
> *"Clone src Cafeqr-Main vào mai/java tạo folder theo từng phần những file nào có sẵn thì thay thế bằng source của tôi"*

### Prompt 2: Yêu cầu lập nhật ký minh chứng AI
> *"trước hết bạn tạo 1 file md vào ai-logs để ghi lại những gì tôi yêu cầu bạn làm"*

### Prompt 3: Thiết lập quy tắc tự động ghi nhớ và lưu vết mọi yêu cầu
> *"hãy tạo 1 md ghi nhớ điều sau 'từ bây giờ tôi yêu cầu bạn làm gì cz sẽ ghi chép lại vào file md kia nhé'"*

### Prompt 4: Kiểm tra trạng thái và URL hoạt động của hệ thống Web
> *"mở url chạy web xem còn hoạt động không"*

### Prompt 5: Kiểm tra đăng nhập trang quản trị bằng tài khoản Admin
> *"mở url lên login vào trang admin bằng tài khoản admin ktra xem có login được hay không"*


---

## 3. Quá trình Xử Lý & Kết Quả do AI Thực Hiện (Raw Output / Action Log)

### 3.1. Cổng Phê Duyệt An Toàn (Approval Gate via `grill-me`)
AI đã khảo sát thư mục nguồn `C:\Users\ad\Downloads\capheQR-main` và hiển thị hộp thoại tương tác làm rõ 3 quyết định trước khi thực thi:
1. Xác nhận phạm vi: Đồng bộ Java Backend + Webapp + Database SQL.
2. Xác nhận cập nhật `pom.xml`: Bổ sung các dependency Jakarta EE, Hibernate, Database Drivers.
3. Phê duyệt kế hoạch hành động.

### 3.2. Cấu Trúc Thư Mục & File Đã Đồng Bộ Vào Dự Án

```
SOF309-MaiTheHai-TS03134/
├── database_postgres.sql                       # Script CSDL PostgreSQL (Supabase)
├── pom.xml                                     # Cấu hình Maven tích hợp đầy đủ dependency
├── docs/
│   └── ai-logs/
│       ├── README.md                           # Hướng dẫn ghi chép minh chứng AI
│       └── 00_project_integration_ai.md        # File nhật ký hiện tại
└── src/
    └── main/
        ├── java/                               # 41 files Java theo từng phân lớp
        │   ├── controller/
        │   │   ├── admin/                      # 9 Servlets quản trị (Attendance, Drink, Employee, Invoice, Login...)
        │   │   ├── api/                        # 2 Servlets API polling (OrderPoll, AttendancePoll)
        │   │   ├── customer/                   # 3 Servlets khách hàng (Menu, PlaceOrder, CheckPoints)
        │   │   └── staff/                      # 3 Servlets nhân viên (StaffOrder, StaffAttendance, StaffTable)
        │   ├── dao/                            # 8 DAOs (UserDao, DrinkDao, OrderDao, CustomerDao, AttendanceDao...)
        │   ├── entity/                         # 9 JPA Entities (User, Drink, Order, OrderDetail, Category, Role...)
        │   ├── filter/                         # 2 Auth Filters (AdminAuthFilter, StaffAuthFilter)
        │   ├── listener/                       # 1 Context Listener (AttendanceAutoCheckoutListener)
        │   ├── utils/                          # 2 Tiện ích (JpaUtils, AlterTableHinhAnh)
        │   └── META-INF/
        │       └── persistence.xml             # Cấu hình Persistence Unit "CoffeeShopPU"
        ├── resources/
        │   └── META-INF/
        │       └── persistence.xml             # Đồng bộ vào resources chuẩn quy cách Maven
        └── webapp/                             # 63 files giao diện Web
            ├── admin/                          # JSP quản trị (dashboard, drinks, employees, invoices, revenue...)
            ├── customer/                       # JSP khách hàng (menu.jsp, order-success.jsp)
            ├── staff/                          # JSP nhân viên (orders.jsp, order-detail.jsp, attendance.jsp...)
            ├── common/                         # File dùng chung (JS)
            ├── images/                         # Ảnh sản phẩm đồ uống & banner
            ├── WEB-INF/
            │   └── web.xml                     # Bộ định tuyến Servlet / JSP
            ├── index.jsp                       # Trang chủ điều hướng
            └── test-db.jsp                     # Trang kiểm tra kết nối CSDL
```

### 3.3. Các Dependency Đã Được Cập Nhật Vào `pom.xml`
- `org.hibernate.orm:hibernate-core:6.5.2.Final`
- `org.hibernate.orm:hibernate-hikaricp:6.5.2.Final`
- `org.postgresql:postgresql:42.7.3`
- `com.microsoft.sqlserver:mssql-jdbc:12.8.1.jre11`
- `jakarta.servlet:jakarta.servlet-api:6.1.0`
- `jakarta.servlet.jsp:jakarta.servlet.jsp-api:4.0.0`
- `jakarta.servlet.jsp.jstl:jakarta.servlet.jsp.jstl-api:3.0.0`
- `org.glassfish.web:jakarta.servlet.jsp.jstl:3.0.1`

### 3.4. Thiết Lập Quy Tắc Tự Động Lưu Vết Mọi Yêu Cầu
- Đã thiết lập quy tắc bắt buộc tại [.antigravity/rules/auto-ai-log-enforcement.md](../../.antigravity/rules/auto-ai-log-enforcement.md) cam kết: Mọi câu lệnh/yêu cầu phát sinh từ sinh viên đều được tự động cập nhật ngay vào tài liệu markdown tương ứng trong `docs/ai-logs/` trước khi phản hồi.

### 3.5. Kiểm Tra Trạng Thái & URL Hoạt Động Của Hệ Thống Web
- **Kiểm tra CSDL (Supabase PostgreSQL):** AI đã thực thi lệnh kiểm tra cổng 6543 tới host `aws-0-ap-southeast-1.pooler.supabase.com` $\rightarrow$ Kết quả: `TcpTestSucceeded = True` (CSDL đám mây đang chạy tốt).
- **Kiểm tra Web Server (Localhost Tomcat):** Port 8080 chưa mở listener (server Tomcat 11 cục bộ chưa được bấm Start trong Eclipse hoặc qua `startup.bat`).
- **Danh sách URL hệ thống khi khởi động:**
  - Trang đăng nhập quản trị: `http://localhost:8080/QRCoffeePoly/admin/login.jsp`
  - Trang đặt món QR khách hàng: `http://localhost:8080/QRCoffeePoly/customer/menu.jsp?table=1`
  - Trang kiểm tra DB: `http://localhost:8080/QRCoffeePoly/test-db.jsp`

### 3.6. Kiểm Tra Đăng Nhập Trang Quản Trị & Chẩn Đoán Trạng Thái Kết Nối CSDL
- **Tài khoản kiểm tra (Database):** `admin@qrcoffee.com` / Mật khẩu: `admin123` (Vai trò: `ADMIN`).
- **Giao diện đăng nhập (`/admin/login.jsp`):** Trả về `HTTP 200 OK`, hiển thị đầy đủ form đăng nhập.
- **Thực thi xác thực (`POST /admin/login`):**
  - Gặp lỗi phản hồi máy chủ `HTTP 500` do `utils.JpaUtils` ném ngoại lệ kết nối: `FATAL: tenant/user postgres.mbtxuxrgdqqmgulbkqwi not found`.
  - **Nguyên nhân kỹ thuật:** Dự án Supabase miễn phí tự động tạm dừng (pause) sau 7 ngày không hoạt động.
  - **Giải pháp:** Sinh viên truy cập bảng điều khiển Supabase tại `https://supabase.com/dashboard/project/mbtxuxrgdqqmgulbkqwi` và bấm nút **Restore Project** để kích hoạt lại CSDL.

---

## 4. Đánh Giá & Kiểm Tra của Sinh Viên
1. **Kiểm tra tính toàn vẹn (Integrity Check):**
   - Đã đối soát số lượng file giữa nguồn và đích: Java source đạt chính xác 41/41 files, Webapp đạt chính xác 63/63 files.
   - Toàn bộ package declaration và import trong từng file Java đều ăn khớp với kiến trúc thư mục.
2. **Tối ưu chuẩn Maven:**
   - Đã bổ sung file [src/main/resources/META-INF/persistence.xml](../../src/main/resources/META-INF/persistence.xml) để khi Maven chạy kiểm thử JUnit (Y3), Hibernate tự động tìm thấy cấu hình kết nối DB trên classpath mà không cần server Tomcat container.
3. **Trạng thái sẵn sàng:**
   - Dự án đã hoàn thành trọn vẹn yêu cầu **Y1** (Tuần 1).
   - Sẵn sàng bước sang yêu cầu **Y2**: Viết đặc tả [docs/SPECIFICATIONS.md](../SPECIFICATIONS.md), tạo [docs/TEST_PLAN.md](../TEST_PLAN.md) và [docs/TEST_CASES.md](../TEST_CASES.md).

