# Project Progress - SOF309 Assignment

## Tổng quan Lộ trình 6 Tuần (Theo HUONG_DAN_CHI_TIET_6_TUAN.md)

- [x] **Y1 (Tuần 1): Tích hợp Web cũ vào repo cá nhân**
  - [x] Sao chép toàn bộ mã nguồn Java Backend từ `capheQR-main` vào `src/main/java/` theo từng package:
    - [x] `controller/` (admin, api, customer, staff)
    - [x] `dao/` (AttendanceDao, CategoryDao, CustomerDao, DrinkDao, OrderDao, RoleDao, TableDao, UserDao)
    - [x] `entity/` (Attendance, Category, Customer, Drink, Order, OrderDetail, Role, Table, User)
    - [x] `filter/` (AdminAuthFilter, StaffAuthFilter)
    - [x] `listener/` (AttendanceAutoCheckoutListener)
    - [x] `utils/` (JpaUtils, AlterTableHinhAnh)
    - [x] `META-INF/` (persistence.xml)
  - [x] Đồng bộ giao diện Web vào `src/main/webapp/` (admin, customer, staff, images, WEB-INF/web.xml)
  - [x] Sao chép script khởi tạo CSDL `database_postgres.sql`
  - [x] Cập nhật `pom.xml` bổ sung Hibernate 6, HikariCP, PostgreSQL Driver, Jakarta Servlet 6.1, JSTL 3.0
  - [x] Xóa file giữ chỗ `.gitkeep`
  - [x] Tạo file nhật ký minh chứng AI `docs/ai-logs/00_project_integration_ai.md` theo biểu mẫu quy định của môn học (Y6 Điểm A)

- [x] **Y2 (Tuần 1): Đặc tả nghiệp vụ & Thiết kế kịch bản kiểm thử (AI RAG)**
  - [x] Cập nhật `docs/SPECIFICATIONS.md` (Đặc tả chi tiết Đăng nhập, CRUD Món, Bàn & QR, Gọi món)
  - [x] Cập nhật `docs/TEST_PLAN.md` (Kế hoạch kiểm thử JUnit 5, Selenium POM, CI/CD)
  - [x] Cập nhật `docs/TEST_CASES.md` (Ma trận EP và BVA chi tiết cho Controller và UI)
  - [x] Tạo file nhật ký minh chứng AI `docs/ai-logs/01_test_design_ai.md` (Y6 Điểm A)
  - [x] Đẩy toàn bộ mã nguồn Tuần 1 lên GitHub an toàn ([SOF309-SD1304-TS03134-MaiTheHai](https://github.com/haimtts03134-del/SOF309-SD1304-TS03134-MaiTheHai)), tuân thủ 100% rule `secret-leak-prevention`

- [ ] **Y3 (Tuần 2): Viết Unit Test Controller với JUnit 5 nâng cao**
- [ ] **Y4 (Tuần 3 & 4): Xây dựng khung kiểm thử tự động UI (Selenium POM + TestNG)**
- [ ] **Y5 (Tuần 5): CI/CD GitHub Actions & Báo cáo tự động**
- [ ] **Y6 (Tuần 6): Hoàn thiện hồ sơ minh chứng AI & Slide bảo vệ**

