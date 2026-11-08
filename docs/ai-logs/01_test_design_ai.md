# Nhật ký AI: Thiết Kế Test Plan & Bộ Test Case Bằng Kỹ Thuật Phân Vùng Tương Đương & Phân Tích Giá Trị Biên (Y2)

> **Môn học:** SOF309 - Kiểm thử nâng cao cùng AI  
> **Sinh viên thực hiện:** Mai Thế Hải - TS03134  
> **Giai đoạn:** Tuần 1 - Yêu cầu Y2 (Assignment)  
> **Ngày thực hiện:** 08/11/2026  

---

## 1. Ngữ cảnh & Mục tiêu
- **Ngữ cảnh:** Đã hoàn thành tích hợp mã nguồn dự án CafeQR (Y1) và xây dựng tài liệu đặc tả nghiệp vụ chi tiết [docs/SPECIFICATIONS.md](../SPECIFICATIONS.md).
- **Mục tiêu thực hiện (Y2):**
  - Đóng vai trò QA Lead, ứng dụng kỹ thuật AI RAG phân tích tài liệu đặc tả chức năng Đăng nhập và CRUD.
  - Áp dụng 2 kỹ thuật kiểm thử hộp đen nâng cao chuẩn quốc tế: **Phân vùng tương đương (Equivalence Partitioning - EP)** và **Phân tích giá trị biên (Boundary Value Analysis - BVA)**.
  - Sinh kế hoạch kiểm thử hoàn chỉnh [docs/TEST_PLAN.md](../TEST_PLAN.md) và ma trận kịch bản chi tiết [docs/TEST_CASES.md](../TEST_CASES.md) cho cả 2 tầng: Unit Test Controller (JUnit 5 - Y3) và Automation UI Test (Selenium WebDriver POM - Y4).

---

## 2. Các câu lệnh đã gửi cho AI (Prompt)

### Prompt 1: Thiết kế Test Plan & Test Case cho chức năng Đăng nhập
> *"Bạn là QA Lead. Dưới đây là đặc tả nghiệp vụ dự án Web của tôi:*  
> *\* **URL màn hình:** `/admin/login.jsp` (Method: `POST /admin/login`)*  
> *\* **Danh sách các trường dữ liệu và ràng buộc validation:***  
> *  1. `email` (Email đăng nhập):*  
> *     \* **Bắt buộc nhập:** Không được để trống (Not empty / Not null).*  
> *     \* **Định dạng:** Phải đúng định dạng chuẩn email (`^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`).*  
> *     \* **Độ dài:** Từ 6 đến 100 ký tự. Tự động loại bỏ khoảng trắng ở hai đầu (Trim).*  
> *  2. `password` (Mật khẩu):*  
> *     \* **Bắt buộc nhập:** Không được để trống.*  
> *     \* **Độ dài:** Tối thiểu 6 ký tự, tối đa 50 ký tự.*  
> *     \* **Đặc thù:** Phân biệt chữ hoa / chữ thường.*  
> *\* **Quy tắc xử lý nghiệp vụ:***  
> *  \* **Hợp lệ (Pass):***  
> *    \* Đúng tài khoản và mật khẩu $\rightarrow$ Chuyển hướng theo phân quyền:*  
> *      \* Nếu có vai trò `ADMIN` hoặc email là `admin@qrcoffee.com`: Gán `hasAdminAccess = true`, chuyển hướng về `/admin/dashboard`.*  
> *      \* Nếu có vai trò `NHANVIEN`: Gán `hasStaffAccess = true`, chuyển hướng về `/staff/orders`.*  
> *  \* **Không hợp lệ (Fail):***  
> *    \* Để trống email hoặc mật khẩu $\rightarrow$ Báo lỗi: "Vui lòng nhập đầy đủ email và mật khẩu".*  
> *    \* Email sai định dạng $\rightarrow$ Báo lỗi: "Email không đúng định dạng".*  
> *    \* Nhập sai mật khẩu hoặc email không tồn tại $\rightarrow$ Báo lỗi: "Tài khoản hoặc mật khẩu không chính xác".*  
> *    \* Tài khoản ở trạng thái vô hiệu hóa (`TrangThai = 'Khoa'`) $\rightarrow$ Báo lỗi: "Tài khoản của bạn đã bị vô hiệu hóa".*  
> *Hãy áp dụng kỹ thuật Phân vùng tương đương và Phân tích giá trị biên để thiết kế Test Plan và Bộ Test Case chi tiết cho Controller và UI."*

### Prompt 2: Mở rộng thiết kế Test Plan & Test Case cho 2 phân hệ còn lại (CRUD Đồ Uống & Đặt Món QR)
> *"Dựa trên đoạn task vừa rồi thay đoạn trường dữ liệu của login thành 2 trường dữ liệu còn lại và viết test plan cũng như test case"*

---

## 3. Kết quả do AI sinh ra (Raw Output)

### 3.1. Thiết Kế Kế Hoạch Kiểm Thử Toàn Diện ([docs/TEST_PLAN.md](../TEST_PLAN.md))
- Mở rộng phạm vi kiểm thử (In-Scope) bao quát đầy đủ 3 phân hệ cốt lõi:
  1. Xác thực & Đăng nhập phân quyền (`/admin/login`).
  2. Quản lý Thực đơn Đồ uống CRUD (`/admin/drinks`).
  3. Menu & Đặt món QR Khách hàng tại bàn (`/customer/place-order`).
- Phân tích chiến lược áp dụng EP và BVA cho từng miền dữ liệu:
  - Độ dài tên món $[2, 100]$ ký tự, Đơn giá $[1,000; 10,000,000]$ VNĐ.
  - Số lượng đặt món $[1, 99]$ ly, Độ dài ghi chú $[0, 200]$ ký tự.

### 3.2. Thiết Kế Bộ Ma Trận Test Case Chi Tiết ([docs/TEST_CASES.md](../TEST_CASES.md))
- **Phân hệ 1: Xác thực & Đăng nhập (`/admin/login`):**
  - **12 EP Test Cases (TC_AUTH_01 $\rightarrow$ TC_AUTH_12):** Bao phủ Admin, Staff, tự động Trim, để trống, sai regex email, sai mật khẩu, phân biệt hoa/thường, tài khoản bị khóa.
  - **8 BVA Test Cases (TC_BVA_AUTH_01 $\rightarrow$ TC_BVA_AUTH_08):** Đo ranh giới biên ký tự Email và Mật khẩu.
- **Phân hệ 2: Quản lý Thực đơn Đồ uống CRUD (`DrinkServlet`):**
  - **10 EP Test Cases (TC_DRINK_EP_01 $\rightarrow$ TC_DRINK_EP_10):** Kiểm tra Thêm/Sửa/Xóa, tên rỗng, tên chứa mã độc script XSS, trùng tên trong danh mục, giá âm, giá bằng 0, không chọn danh mục, xóa mềm bảo toàn hóa đơn.
  - **12 BVA Test Cases (TC_DRINK_BVA_01 $\rightarrow$ TC_DRINK_BVA_12):** Đo chuẩn xác các điểm ranh giới $Min-1, Min, Min+1, Max-1, Max, Max+1$ cho độ dài tên (1, 2, 3, 99, 100, 101) và đơn giá (0, 999, 1000, 1001, 10000000, 10000001 VNĐ).
- **Phân hệ 3: Đặt món QR Khách hàng (`PlaceOrderServlet`):**
  - **7 EP Test Cases (TC_ORDER_EP_01 $\rightarrow$ TC_ORDER_EP_07):** Giỏ hàng hợp lệ, giỏ rỗng, bàn không tồn tại, món hết hàng, số lượng âm, số lượng lẻ, không ghi chú.
  - **10 BVA Test Cases (TC_ORDER_BVA_01 $\rightarrow$ TC_ORDER_BVA_10):** Đo ranh giới biên số lượng ly (0, 1, 2, 98, 99, 100) và độ dài ghi chú (0, 1, 200, 201 ký tự).
- **Bộ Kịch Bản Tự Động Hóa Giao Diện (Selenium UI POM):**
  - **6 Test Cases (TC_UI_01 $\rightarrow$ TC_UI_06):** Bao quát đăng nhập thành công/thất bại, thêm món nước và bắt lỗi giá $= 0$ trên giao diện, khách hàng đặt món QR thành công và cảnh báo giỏ hàng rỗng.

---

## 4. Đánh Giá & Chỉnh Sửa của Sinh Viên
1. **Tính tương thích với Codebase:**
   - Bộ Test Case đã đối soát trực tiếp với mã nguồn thực tế của [`LoginServlet.java`](../../src/main/java/controller/admin/LoginServlet.java), [`DrinkServlet.java`](../../src/main/java/controller/admin/DrinkServlet.java) và [`PlaceOrderServlet.java`](../../src/main/java/controller/customer/PlaceOrderServlet.java).
2. **Sẵn sàng cho Tuần 2 (Y3 - Unit Test):**
   - Các dữ liệu kiểm thử trong bảng EP và BVA được thiết kế có cấu trúc bảng rõ ràng, sẵn sàng để nạp trực tiếp vào annotation `@ParameterizedTest` kết hợp `@CsvSource` trong JUnit 5 mà không cần phải viết lại dữ liệu giả lập.
3. **Nghiệm thu Yêu cầu Y2:**
   - Hoàn thành trọn vẹn yêu cầu **Y2** của Tuần 1, tạo nền tảng vững chắc cho quá trình lập trình kiểm thử tự động của các tuần tiếp theo.

