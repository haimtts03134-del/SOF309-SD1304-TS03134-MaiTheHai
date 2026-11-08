# KẾ HOẠCH KIỂM THỬ HỆ THỐNG CAFEQR (TEST PLAN)

> **Môn học:** SOF309 - Kiểm thử nâng cao cùng AI  
> **Dự án:** Hệ thống Quản lý Quán Cà phê & Đặt món qua mã QR (CafeQR / QRCoffeePoly)  
> **Sinh viên thực hiện:** Mai Thế Hải - Mã SV: TS03134  
> **Vai trò:** QA Lead & Automation Tester  
> **Phiên bản:** 2.0 (Mở rộng toàn diện các phân hệ: Login, CRUD Đồ Uống & Đặt Món QR)

---

## 1. TỔNG QUAN & MỤC TIÊU KIỂM THỬ (TEST OBJECTIVES)
1. **Kiểm thử Đơn vị Controller (Unit Test - Y3):**
   * Đảm bảo toàn bộ logic xử lý nghiệp vụ của Controller ([`LoginServlet`](file:///c:/Users/ad/Downloads/SOF309-MaiTheHai-TS03134/src/main/java/controller/admin/LoginServlet.java), [`DrinkServlet`](file:///c:/Users/ad/Downloads/SOF309-MaiTheHai-TS03134/src/main/java/controller/admin/DrinkServlet.java), [`PlaceOrderServlet`](file:///c:/Users/ad/Downloads/SOF309-MaiTheHai-TS03134/src/main/java/controller/customer/PlaceOrderServlet.java)) được kiểm chứng độ phủ 100% với các miền giá trị tương đương và điểm ranh giới biên bằng JUnit 5.
   * Ứng dụng `@ParameterizedTest`, `@CsvSource`, `@MethodSource` và bắt ngoại lệ `assertThrows`.
2. **Kiểm thử Giao diện Tự động (Automation UI Test - Y4):**
   * Xây dựng khung kiểm thử tự động theo mô hình **Page Object Model (POM)** kết hợp Selenium WebDriver và TestNG.
   * Tự động hóa các thao tác người dùng trên trình duyệt: Đăng nhập phân quyền, Thêm/Sửa/Xóa thực đơn món, và Khách hàng thao tác đặt món qua mã QR.
3. **Tích hợp Tự động hóa CI/CD (Y5):**
   * Tự động thực thi toàn bộ kịch bản kiểm thử trên GitHub Actions (môi trường máy chủ Ubuntu, Chrome Headless).

---

## 2. PHẠM VI KIỂM THỬ (TEST SCOPE)

### 2.1. Trong phạm vi (In-Scope):
1. **Phân hệ Xác thực & Đăng nhập (`/admin/login`):**
   * Phân vùng tương đương (EP) và phân tích giá trị biên (BVA) cho Email [6, 100 ký tự] và Password [6, 50 ký tự].
   * Kiểm soát phân quyền (`ADMIN` vs `NHANVIEN`) và trạng thái tài khoản (`HoatDong` vs `Khoa`).
2. **Phân hệ Quản lý Thực đơn / Đồ uống CRUD (`/admin/drinks`):**
   * Kiểm thử biên cho Đơn giá bán ($Giá > 0$ VNĐ, miền biên $[1,000; 10,000,000]$ VNĐ).
   * Kiểm thử biên cho Độ dài tên đồ uống $[2, 100]$ ký tự; ràng buộc duy nhất (Unique per Category); lọc ký tự mã độc XSS.
   * Kiểm thử tính toàn vẹn khóa ngoại danh mục (`DanhMuc`) và cơ chế xóa mềm (Soft Delete) khi món đã phát sinh hóa đơn.
3. **Phân hệ Menu & Đặt món QR Khách hàng (`/customer/place-order`):**
   * Kiểm thử ràng buộc mã bàn (`maBan`), kiểm tra bàn tồn tại và sẵn sàng đón khách.
   * Kiểm thử biên số lượng đặt từng món $[1, 99]$; kiểm thử giỏ hàng tối thiểu $N \ge 1$ món.
   * Kiểm thử độ dài ghi chú món $[0, 200]$ ký tự; kiểm thử trạng thái đơn hàng `ChoXacNhan` và đổi trạng thái bàn sang `CoKhach`.

### 2.2. Ngoài phạm vi (Out-of-Scope):
* Kiểm thử hiệu năng chịu tải đồng thời (Performance / Load Test).
* Kiểm thử thâm nhập an ninh mạng chuyên sâu (Penetration Test).

---

## 3. CHIẾN LƯỢC & PHƯƠNG PHÁP THIẾT KẾ TEST (TEST DESIGN TECHNIQUES)

### 3.1. Kỹ Thuật Phân Vùng Tương Đương (Equivalence Partitioning - EP)

| Phân hệ / Trường dữ liệu | Miền Hợp Lệ (Valid Equivalence Class) | Miền Không Hợp Lệ (Invalid Equivalence Class) |
| :--- | :--- | :--- |
| **Login: `email`** | • Chuẩn RFC 5322 (`admin@qrcoffee.com`)<br>• Tồn tại trong CSDL và đang hoạt động | • Để trống / Null (`""`)<br>• Sai định dạng thiếu `@` hoặc domain<br>• Email không tồn tại trong hệ thống |
| **Login: `password`** | • Đúng mật khẩu đã lưu trong DB<br>• Đúng chữ hoa, chữ thường | • Để trống / Null (`""`)<br>• Độ dài $< 6$ ký tự<br>• Sai mật khẩu hoặc sai hoa/thường |
| **Drink: `tenSanPham`** | • Độ dài 2 - 100 ký tự hợp lệ<br>• Chưa tồn tại trong danh mục đã chọn | • Để trống / Chỉ chứa khoảng trắng<br>• Độ dài $< 2$ ký tự<br>• Trùng tên món trong cùng danh mục<br>• Chứa thẻ script độc hại (`<script>`) |
| **Drink: `gia`** | • Số thực/thập phân nằm trong khoảng $[1,000; 10,000,000]$ VNĐ | • Giá bằng 0 VNĐ (`0`)<br>• Giá âm (`-20,000`)<br>• Chứa ký tự chữ (`"abc"`)<br>• Vượt quá $10,000,000$ VNĐ |
| **Drink: `maDanhMuc`** | • Mã ID danh mục tồn tại trong bảng `DanhMuc` | • Để trống/null<br>• ID không tồn tại trong CSDL (`99999`) |
| **Order: `maBan`** | • Mã bàn hợp lệ tồn tại trong bảng `Ban` | • Để trống/null<br>• Mã bàn không tồn tại |
| **Order: `soLuong`** | • Số nguyên dương nằm trong khoảng $[1; 99]$ | • Số lượng bằng 0 (`0`)<br>• Số âm (`-2`)<br>• Số thập phân lẻ (`1.5`)<br>• Vượt quá 99 (`100`) |
| **Order: `ghiChu`** | • Để trống (cho phép) hoặc chuỗi $\le 200$ ký tự | • Độ dài chuỗi vượt quá 200 ký tự |

---

### 3.2. Kỹ Thuật Phân Tích Giá Trị Biên (Boundary Value Analysis - BVA)

#### A. Phân Hệ Quản Lý Đồ Uống CRUD (`/admin/drinks`)
* **Biên Độ Dài Tên Món [2, 100] ký tự:**
  * $L = 1$: Biên Invalid dưới (`"A"`) $\rightarrow$ Báo lỗi tên tối thiểu 2 ký tự.
  * $L = 2$: Biên Valid tối thiểu (`"Tr"`) $\rightarrow$ Hợp lệ.
  * $L = 3$: Cận biên Valid (`"Tra"`) $\rightarrow$ Hợp lệ.
  * $L = 99$ & $L = 100$: Biên Valid tối đa $\rightarrow$ Hợp lệ.
  * $L = 101$: Biên Invalid trên $\rightarrow$ Báo lỗi tên tối đa 100 ký tự.
* **Biên Đơn Giá Bán [1,000; 10,000,000] VNĐ:**
  * $G = 0$ VNĐ: Biên Invalid dưới $\rightarrow$ Báo lỗi: *"Đơn giá phải lớn hơn 0"*.
  * $G = 999$ VNĐ: Cận biên dưới Invalid $\rightarrow$ Báo lỗi: Đơn giá tối thiểu từ 1,000 VNĐ.
  * $G = 1,000$ VNĐ: Biên Valid tối thiểu $\rightarrow$ Hợp lệ.
  * $G = 1,001$ VNĐ: Cận biên Valid $\rightarrow$ Hợp lệ.
  * $G = 9,999,999$ & $10,000,000$ VNĐ: Biên Valid tối đa $\rightarrow$ Hợp lệ.
  * $G = 10,000,001$ VNĐ: Biên Invalid trên $\rightarrow$ Báo lỗi vượt hạn mức giá cho phép.

#### B. Phân Hệ Đặt Món QR Khách Hàng (`/customer/place-order`)
* **Biên Số Lượng Món [1, 99]:**
  * $S = 0$: Biên Invalid dưới $\rightarrow$ Báo lỗi: Số lượng đặt tối thiểu là 1.
  * $S = 1$: Biên Valid tối thiểu $\rightarrow$ Hợp lệ.
  * $S = 2$: Cận biên Valid $\rightarrow$ Hợp lệ.
  * $S = 98$ & $S = 99$: Biên Valid tối đa $\rightarrow$ Hợp lệ.
  * $S = 100$: Biên Invalid trên $\rightarrow$ Báo lỗi: Số lượng đặt tối đa là 99 cho mỗi món.
* **Biên Độ Dài Ghi Chú [0, 200] ký tự:**
  * $L = 0$: Biên Valid tối thiểu (không ghi chú) $\rightarrow$ Hợp lệ.
  * $L = 1$: Hợp lệ.
  * $L = 199$ & $L = 200$: Biên Valid tối đa $\rightarrow$ Hợp lệ.
  * $L = 201$: Biên Invalid trên $\rightarrow$ Báo lỗi ghi chú vượt quá 200 ký tự.

---

## 4. TIÊU CHÍ NGHIỆM THU PASS/FAIL (ACCEPTANCE CRITERIA)
* **Unit Test JUnit 5 (Y3):** Toàn bộ các test cases EP và BVA của `LoginServlet`, `DrinkServlet`, `PlaceOrderServlet` thực thi với lệnh `mvn test` đạt 100% Pass (Xanh).
* **Selenium UI Test POM (Y4):** Tự động hóa kiểm thử đầy đủ các form, hiển thị chuẩn xác thông báo lỗi inline/alert và chuyển hướng đúng URL theo phân quyền.
