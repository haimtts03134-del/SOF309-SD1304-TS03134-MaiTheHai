# ĐẶC TẢ NGHIỆP VỤ WEB CÁ NHÂN (SPECIFICATIONS)
> *Tài liệu đặc tả chi tiết nghiệp vụ dự án CafeQR dùng làm ngữ cảnh (Context) gửi cho AI để áp dụng kỹ thuật Phân vùng tương đương và Phân tích giá trị biên sinh Test Plan & Bộ Test Case.*

---

## 1. THÔNG TIN DỰ ÁN
* **Tên đề tài:** Hệ thống Quản lý Quán Cà phê Thông minh & Đặt món qua mã QR (CafeQR / QRCoffeePoly)
* **Sinh viên thực hiện:** Mai Thế Hải - Mã SV: TS03134
* **Công nghệ:** Java 17 / 25, Jakarta Servlet 6.1, JSP 4.0, Hibernate ORM 6.5, PostgreSQL / SQL Server
* **URL chạy local:** `http://localhost:8080/QRCoffeePoly`

---

## 2. DANH SÁCH URL CÁC MÀN HÌNH CHÍNH
* **Màn hình Đăng nhập:** `http://localhost:8080/QRCoffeePoly/admin/login.jsp` (Xử lý: `POST /admin/login`)
* **Màn hình Quản lý Sản phẩm / Đồ uống (CRUD):** `http://localhost:8080/QRCoffeePoly/admin/drinks`
* **Màn hình Menu Thực đơn & Đặt món QR Khách hàng:** `http://localhost:8080/QRCoffeePoly/customer/menu.jsp?table=1` (Xử lý: `POST /customer/place-order`)
* **Màn hình Bảng điều khiển Quản trị:** `http://localhost:8080/QRCoffeePoly/admin/dashboard`
* **Màn hình Quản lý Bàn & Mã QR:** `http://localhost:8080/QRCoffeePoly/admin/tables`

---

## 3. DANH SÁCH CÁC TRƯỜNG DỮ LIỆU & RÀNG BUỘC VALIDATION

### 3.1. Chức Năng Đăng Nhập (`/admin/login`)
* **URL màn hình:** `/admin/login.jsp` (Method: `POST /admin/login`)
* **Danh sách các trường dữ liệu và ràng buộc validation:**
  1. `email` (Email đăng nhập):
     * **Bắt buộc nhập:** Không được để trống (Not empty / Not null).
     * **Định dạng:** Phải đúng định dạng chuẩn email (`^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`).
     * **Độ dài:** Từ 6 đến 100 ký tự. Tự động loại bỏ khoảng trắng ở hai đầu (Trim).
  2. `password` (Mật khẩu):
     * **Bắt buộc nhập:** Không được để trống.
     * **Độ dài:** Tối thiểu 6 ký tự, tối đa 50 ký tự.
     * **Đặc thù:** Phân biệt chữ hoa / chữ thường.
* **Quy tắc xử lý nghiệp vụ:**
  * **Hợp lệ (Pass):**
    * Đúng tài khoản và mật khẩu $\rightarrow$ Chuyển hướng theo phân quyền:
      * Nếu có vai trò `ADMIN` hoặc email là `admin@qrcoffee.com`: Gán `hasAdminAccess = true`, chuyển hướng về `/admin/dashboard`.
      * Nếu có vai trò `NHANVIEN`: Gán `hasStaffAccess = true`, chuyển hướng về `/staff/orders`.
  * **Không hợp lệ (Fail):**
    * Để trống email hoặc mật khẩu $\rightarrow$ Báo lỗi: *"Vui lòng nhập đầy đủ email và mật khẩu"*.
    * Email sai định dạng $\rightarrow$ Báo lỗi: *"Email không đúng định dạng"*.
    * Nhập sai mật khẩu hoặc email không tồn tại $\rightarrow$ Báo lỗi: *"Tài khoản hoặc mật khẩu không chính xác"*.
    * Tài khoản ở trạng thái vô hiệu hóa (`TrangThai = 'Khoa'`) $\rightarrow$ Báo lỗi: *"Tài khoản của bạn đã bị vô hiệu hóa"*.

---

### 3.2. Chức Năng Quản Lý Sản Phẩm / Đồ Uống CRUD (`/admin/drinks`)
* **URL màn hình:** `/admin/drinks` (Method: `POST /admin/drinks`)
* **Danh sách các trường dữ liệu và ràng buộc validation:**
  1. `tenSanPham` (Tên đồ uống):
     * **Bắt buộc nhập:** Không được để trống hoặc chỉ chứa khoảng trắng.
     * **Độ dài:** Từ 2 đến 100 ký tự.
     * **Ký tự đặc biệt:** Không chứa các thẻ mã độc HTML/Script (`<script>`, `<`, `>`) để phòng chống XSS.
     * **Ràng buộc duy nhất:** Không được trùng tên với sản phẩm đã có trong cùng một danh mục.
  2. `gia` (Đơn giá bán):
     * **Bắt buộc nhập:** Định dạng số thập phân dương (`BigDecimal`).
     * **Ràng buộc giá trị:** **Giá bán phải $> 0$ VNĐ** (Ngưỡng giá trị hợp lệ: từ $1,000$ VNĐ đến $10,000,000$ VNĐ).
     * **Giá trị biên kiểm thử:** Giá trị $\le 0$, giá trị âm, hoặc nhập chữ/ký tự lạ $\rightarrow$ Báo lỗi: *"Đơn giá phải lớn hơn 0"*.
  3. `maDanhMuc` (Danh mục đồ uống):
     * **Bắt buộc chọn:** Phải chọn một danh mục hợp lệ từ danh sách (Cà phê, Trà sữa, Nước ép...).
     * **Ràng buộc khóa ngoại:** ID danh mục phải tồn tại trong bảng `DanhMuc`.
  4. `trangThai` (Trạng thái bán):
     * **Giá trị quy chuẩn:** Nhận một trong hai giá trị `ConHang` (Còn hàng) hoặc `HetHang` (Hết hàng).
  5. `hinhAnh` (Ảnh minh họa món):
     * **Định dạng:** Chấp nhận các đuôi ảnh hợp lệ (`.jpg`, `.jpeg`, `.png`, `.webp`) hoặc URL ảnh.
     * **Dung lượng:** Giới hạn kích thước file upload $\le 5$ MB.
* **Quy tắc xử lý nghiệp vụ CRUD:**
  * **Thêm mới (Create):** Thỏa mãn đầy đủ validation $\rightarrow$ Lưu bản ghi mới vào CSDL, hiển thị thông báo thêm thành công.
  * **Cập nhật (Update):** Nạp thông tin sản phẩm theo `maSanPham` lên form, kiểm tra ràng buộc tên và giá trước khi lưu cập nhật.
  * **Xóa (Delete):**
    * Bắt buộc có hộp thoại xác nhận 2 bước trước khi xóa.
    * **Xóa mềm (Soft Delete):** Nếu sản phẩm đã từng phát sinh giao dịch trong bảng `ChiTietHoaDon`, hệ thống tự động đổi `trangThai = 'HetHang'` thay vì xóa cứng để bảo vệ tính toàn vẹn dữ liệu kế toán/doanh thu.

---

### 3.3. Chức Năng Menu & Đặt Món QR Khách Hàng (`/customer/place-order`)
* **URL màn hình:** `/customer/menu.jsp?table={id}` (Method: `POST /customer/place-order`)
* **Danh sách các trường dữ liệu và ràng buộc validation:**
  1. `maBan` (Mã số bàn):
     * **Bắt buộc:** Phải được truyền qua URL parameter hoặc Session (Ví dụ: `?table=1`).
     * **Ràng buộc:** Mã bàn phải tồn tại trong bảng `Ban` và bàn đang ở trạng thái sẵn sàng phục vụ.
  2. `cartItems` (Danh sách món đã chọn):
     * **Bắt buộc:** Giỏ hàng phải có tối thiểu 1 món ($N \ge 1$).
  3. `soLuong` (Số lượng từng món):
     * **Ràng buộc giá trị:** Phải là số nguyên dương trong khoảng **$1 \le \text{soLuong} \le 99$**.
     * **Bác bỏ:** Số lượng bằng $0$, số âm hoặc số thập phân lẻ $\rightarrow$ Báo lỗi không hợp lệ.
  4. `ghiChu` (Ghi chú món):
     * **Tùy chọn:** Độ dài không vượt quá 200 ký tự (Ví dụ: "Không đường, ít đá").
* **Quy tắc xử lý nghiệp vụ:**
  * Khách bấm "Đặt món" $\rightarrow$ Tạo bản ghi trong bảng `HoaDon` với trạng thái `ChoXacNhan`.
  * Tự động cập nhật trạng thái bàn sang `CoKhach` (Đang có khách).
  * Chuyển hướng người dùng sang trang [order-success.jsp](file:///c:/Users/ad/Downloads/SOF309-MaiTheHai-TS03134/src/main/webapp/customer/order-success.jsp) hiển thị hóa đơn tạm tính.

---

## 4. TÀI KHOẢN MẪU PHỤC VỤ KIỂM THỬ TỰ ĐỘNG (TEST SUITE)
* **Tài khoản Quản trị viên (Admin):**
  * Email: `admin@qrcoffee.com`
  * Mật khẩu: `admin123`
* **Tài khoản Nhân viên (Staff):**
  * Email: `binh.tt@qrcoffee.com`
  * Mật khẩu: `staff123`
