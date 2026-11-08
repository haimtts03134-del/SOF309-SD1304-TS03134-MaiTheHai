# BỘ MA TRẬN KỊCH BẢN KIỂM THỬ (TEST CASES MATRIX)

> **Môn học:** SOF309 - Kiểm thử nâng cao cùng AI  
> **Dự án:** Hệ thống Quản lý Quán Cà phê & Đặt món qua mã QR (CafeQR / QRCoffeePoly)  
> **Sinh viên thực hiện:** Mai Thế Hải - Mã SV: TS03134  
> **Phương pháp thiết kế:** Phân vùng tương đương (EP) & Phân tích giá trị biên (BVA)  
> **Bao quát đầy đủ 3 phân hệ:** Xác thực Đăng nhập, Quản lý Thực đơn Đồ uống CRUD và Đặt món QR Khách hàng.

---

## PHẦN I. MA TRẬN KIỂM THỬ XÁC THỰC & ĐĂNG NHẬP (`/admin/login`)

### 1. Phân Vùng Tương Đương (Equivalence Partitioning - EP)

| Test Case ID | Phân tầng | Mô tả ca kiểm thử | Loại | Kỹ thuật | Dữ liệu kiểm thử (Input) | Kết quả mong đợi (Expected Result) |
| :---: | :---: | :--- | :---: | :---: | :--- | :--- |
| **TC_AUTH_01** | Controller/UI | Đăng nhập tài khoản Quản trị (Admin) hợp lệ | Positive | Valid EP | `email = "admin@qrcoffee.com"`<br>`password = "admin123"` | Xác thực thành công; `hasAdminAccess = true`; Chuyển hướng về `/admin/dashboard`. |
| **TC_AUTH_02** | Controller/UI | Đăng nhập tài khoản Nhân viên (Staff) hợp lệ | Positive | Valid EP | `email = "binh.tt@qrcoffee.com"`<br>`password = "staff123"` | Xác thực thành công; `hasStaffAccess = true`; Chuyển hướng về `/staff/orders`. |
| **TC_AUTH_03** | Controller/UI | Đăng nhập thất bại khi để trống Email | Negative | Invalid EP | `email = ""` \| `password = "admin123"` | Bị chặn; Báo lỗi: *"Vui lòng nhập đầy đủ email và mật khẩu"*. |
| **TC_AUTH_04** | Controller/UI | Đăng nhập thất bại khi để trống Mật khẩu | Negative | Invalid EP | `email = "admin@qrcoffee.com"` \| `password = ""` | Bị chặn; Báo lỗi: *"Vui lòng nhập đầy đủ email và mật khẩu"*. |
| **TC_AUTH_05** | Controller/UI | Đăng nhập thất bại khi để trống cả hai trường | Negative | Invalid EP | `email = ""` \| `password = ""` | Bị chặn; Báo lỗi thiếu thông tin đăng nhập. |
| **TC_AUTH_06** | Controller/UI | Đăng nhập thất bại khi Email thiếu ký tự `@` | Negative | Invalid EP | `email = "adminqrcoffee.com"` \| `password = "admin123"` | Báo lỗi: *"Email không đúng định dạng"*. |
| **TC_AUTH_07** | Controller/UI | Đăng nhập thất bại khi Email thiếu tên miền | Negative | Invalid EP | `email = "admin@"` \| `password = "admin123"` | Báo lỗi: *"Email không đúng định dạng"*. |
| **TC_AUTH_08** | Controller/UI | Tự động Trim khoảng trắng thừa ở hai đầu | Positive | Valid EP | `email = "  admin@qrcoffee.com  "` \| `password = "admin123"` | Tự động trim khoảng trắng và đăng nhập thành công vào `/admin/dashboard`. |
| **TC_AUTH_09** | Controller/UI | Đăng nhập thất bại với Email không tồn tại | Negative | Invalid EP | `email = "unknown@qrcoffee.com"` \| `password = "admin123"` | Báo lỗi: *"Tài khoản hoặc mật khẩu không chính xác"*. |
| **TC_AUTH_10** | Controller/UI | Đăng nhập thất bại khi nhập sai Mật khẩu | Negative | Invalid EP | `email = "admin@qrcoffee.com"` \| `password = "wrongpass"` | Báo lỗi: *"Tài khoản hoặc mật khẩu không chính xác"*. |
| **TC_AUTH_11** | Controller/UI | Phân biệt chữ hoa / chữ thường mật khẩu | Negative | Invalid EP | `email = "admin@qrcoffee.com"` \| `password = "ADMIN123"` | Mật khẩu sai chữ hoa/thường $\rightarrow$ Báo lỗi *"Tài khoản hoặc mật khẩu không chính xác"*. |
| **TC_AUTH_12** | Controller/UI | Đăng nhập bằng tài khoản bị khóa (`Khoa`) | Negative | Invalid EP | `email = "khoa.tk@qrcoffee.com"` \| `password = "staff123"` | Báo lỗi: *"Tài khoản của bạn đã bị vô hiệu hóa"*. |

### 2. Phân Tích Giá Trị Biên (Boundary Value Analysis - BVA)

| Test Case ID | Mục tiêu kiểm thử | Ranh giới | Dữ liệu kiểm thử (Input) | Chiều dài | Kết quả mong đợi |
| :---: | :--- | :---: | :--- | :---: | :--- |
| **TC_BVA_AUTH_01** | Độ dài Email | Min - 1 (Invalid) | `a@b.c` | 5 | Báo lỗi độ dài email không hợp lệ ($< 6$ ký tự). |
| **TC_BVA_AUTH_02** | Độ dài Email | Min (Valid) | `a@b.co` | 6 | Hợp lệ, tiến hành xác thực. |
| **TC_BVA_AUTH_03** | Độ dài Email | Max (Valid) | Chuỗi email 100 ký tự | 100 | Hợp lệ, hệ thống chấp nhận chuỗi. |
| **TC_BVA_AUTH_04** | Độ dài Email | Max + 1 (Invalid) | Chuỗi email 101 ký tự | 101 | Báo lỗi độ dài email vượt quá ngưỡng cho phép ($> 100$). |
| **TC_BVA_AUTH_05** | Độ dài Password | Min - 1 (Invalid) | `12345` | 5 | Báo lỗi: Mật khẩu tối thiểu phải từ 6 ký tự trở lên. |
| **TC_BVA_AUTH_06** | Độ dài Password | Min (Valid) | `123456` | 6 | Mật khẩu đủ độ dài hợp lệ. |
| **TC_BVA_AUTH_07** | Độ dài Password | Max (Valid) | Mật khẩu 50 ký tự | 50 | Mật khẩu hợp lệ. |
| **TC_BVA_AUTH_08** | Độ dài Password | Max + 1 (Invalid) | Mật khẩu 51 ký tự | 51 | Báo lỗi: Mật khẩu không được vượt quá 50 ký tự. |

---

## PHẦN II. MA TRẬN KIỂM THỬ QUẢN LÝ ĐỒ UỐNG CRUD (`/admin/drinks`)

### 1. Phân Vùng Tương Đương (Equivalence Partitioning - EP)

| Test Case ID | Phân tầng | Mô tả ca kiểm thử | Loại | Kỹ thuật | Dữ liệu kiểm thử (Input Data) | Kết quả mong đợi (Expected Result) |
| :---: | :---: | :--- | :---: | :---: | :--- | :--- |
| **TC_DRINK_EP_01** | Controller/UI | Thêm món đồ uống mới với thông tin hợp lệ | Positive | Valid EP | Tên: `"Trà Đào Cam Sả"`<br>Giá: `35,000` VNĐ<br>Danh mục: `1` (Trà trái cây)<br>Trạng thái: `ConHang` | Thêm thành công; Bản ghi xuất hiện trong CSDL bảng `SanPham`; Hiển thị thông báo thành công. |
| **TC_DRINK_EP_02** | Controller/UI | Thêm món thất bại khi để trống tên đồ uống | Negative | Invalid EP | Tên: `""` (Rỗng)<br>Giá: `35,000` VNĐ<br>Danh mục: `1` | Bị chặn; Báo lỗi: *"Tên sản phẩm không được để trống"*. Không ghi vào DB. |
| **TC_DRINK_EP_03** | Controller/UI | Thêm món thất bại khi tên chứa mã độc script XSS | Negative | Invalid EP | Tên: `"<script>alert('hack')</script>"`<br>Giá: `35,000` VNĐ | Hệ thống lọc/từ chối mã độc; Báo lỗi: *"Tên sản phẩm chứa ký tự không hợp lệ"*. |
| **TC_DRINK_EP_04** | Controller/UI | Thêm món thất bại khi trùng tên trong danh mục | Negative | Invalid EP | Tên: `"Cà phê sữa đá"` (Đã tồn tại trong DM Cà phê)<br>Giá: `25,000` VNĐ | Ném ngoại lệ nghiệp vụ; Báo lỗi: *"Tên sản phẩm đã tồn tại trong danh mục"*. |
| **TC_DRINK_EP_05** | Controller/UI | Thêm món thất bại khi đơn giá bằng 0 VNĐ | Negative | Invalid EP | Tên: `"Trà Đá Miễn Phí"`<br>Giá: `0` VNĐ | Bị chặn; Báo lỗi: *"Đơn giá phải lớn hơn 0"*. |
| **TC_DRINK_EP_06** | Controller/UI | Thêm món thất bại khi đơn giá là số âm | Negative | Invalid EP | Tên: `"Nước Lọc"`<br>Giá: `-10,000` VNĐ | Bị chặn; Báo lỗi: *"Đơn giá phải lớn hơn 0"*. |
| **TC_DRINK_EP_07** | Controller/UI | Thêm món thất bại khi đơn giá nhập ký tự chữ | Negative | Invalid EP | Tên: `"Sinh tố bơ"`<br>Giá: `"ba mươi lăm nghìn"` | Báo lỗi định dạng: *"Đơn giá phải là số hợp lệ"*. |
| **TC_DRINK_EP_08** | Controller/UI | Thêm món thất bại khi không chọn danh mục | Negative | Invalid EP | Tên: `"Trà Oolong"`<br>Giá: `30,000` VNĐ<br>Danh mục: `null` | Báo lỗi: *"Vui lòng chọn danh mục cho sản phẩm"*. |
| **TC_DRINK_EP_09** | Controller/UI | Cập nhật thông tin đồ uống hợp lệ | Positive | Valid EP | Mã: `1` \| Tên mới: `"Cà phê Đen Đậm Vị"` \| Giá mới: `22,000` VNĐ | Cập nhật thành công thông tin vào bảng `SanPham`. |
| **TC_DRINK_EP_10** | Controller/UI | Xóa mềm đồ uống đã từng phát sinh hóa đơn | Positive | Business Logic | Yêu cầu xóa món `MaSanPham = 1` (đã nằm trong `ChiTietHoaDon`) | Hệ thống tự động chuyển `trangThai = 'HetHang'`, không xóa cứng bản ghi khỏi CSDL. |

### 2. Phân Tích Giá Trị Biên (Boundary Value Analysis - BVA)

| Test Case ID | Trường kiểm thử | Ranh giới kiểm tra | Dữ liệu kiểm thử (Input) | Chiều dài / Giá trị | Kết quả mong đợi |
| :---: | :--- | :---: | :--- | :---: | :--- |
| **TC_DRINK_BVA_01** | Độ dài tên món | Min - 1 (Invalid) | `"A"` | 1 ký tự | Báo lỗi: Tên đồ uống tối thiểu phải từ 2 ký tự. |
| **TC_DRINK_BVA_02** | Độ dài tên món | Min (Valid) | `"Tr"` | 2 ký tự | Hợp lệ, hệ thống chấp nhận tên sản phẩm. |
| **TC_DRINK_BVA_03** | Độ dài tên món | Min + 1 (Valid) | `"Tra"` | 3 ký tự | Hợp lệ. |
| **TC_DRINK_BVA_04** | Độ dài tên món | Max - 1 (Valid) | Chuỗi 99 ký tự hợp lệ | 99 ký tự | Hợp lệ. |
| **TC_DRINK_BVA_05** | Độ dài tên món | Max (Valid) | Chuỗi 100 ký tự hợp lệ | 100 ký tự | Hợp lệ. |
| **TC_DRINK_BVA_06** | Độ dài tên món | Max + 1 (Invalid) | Chuỗi 101 ký tự | 101 ký tự | Báo lỗi: Tên đồ uống không được vượt quá 100 ký tự. |
| **TC_DRINK_BVA_07** | Đơn giá bán | Biên dưới Invalid | `0` VNĐ | 0 | Báo lỗi: Đơn giá phải lớn hơn 0 VNĐ. |
| **TC_DRINK_BVA_08** | Đơn giá bán | Cận biên dưới Invalid | `999` VNĐ | 999 | Báo lỗi: Đơn giá tối thiểu phải từ 1,000 VNĐ. |
| **TC_DRINK_BVA_09** | Đơn giá bán | Min (Valid) | `1,000` VNĐ | 1,000 | Hợp lệ, hệ thống chấp nhận đơn giá. |
| **TC_DRINK_BVA_10** | Đơn giá bán | Min + 1 (Valid) | `1,001` VNĐ | 1,001 | Hợp lệ. |
| **TC_DRINK_BVA_11** | Đơn giá bán | Max (Valid) | `10,000,000` VNĐ | 10,000,000 | Hợp lệ, mức giá cao cấp chấp nhận được. |
| **TC_DRINK_BVA_12** | Đơn giá bán | Max + 1 (Invalid) | `10,000,001` VNĐ | 10,000,001 | Báo lỗi: Đơn giá vượt quá mức tối đa quy định. |

---

## PHẦN III. MA TRẬN KIỂM THỬ ĐẶT MÓN QR KHÁCH HÀNG (`/customer/place-order`)

### 1. Phân Vùng Tương Đương (Equivalence Partitioning - EP)

| Test Case ID | Phân tầng | Mô tả ca kiểm thử | Loại | Kỹ thuật | Dữ liệu kiểm thử (Input Data) | Kết quả mong đợi (Expected Result) |
| :---: | :---: | :--- | :---: | :---: | :--- | :--- |
| **TC_ORDER_EP_01** | Controller/UI | Khách đặt món thành công với giỏ hàng hợp lệ | Positive | Valid EP | Bàn: `1`<br>Món: `Cà phê sữa đá` (SL: 2)<br>Ghi chú: `"Ít ngọt"` | Tạo hóa đơn mới trạng thái `ChoXacNhan`; Chuyển trạng thái bàn sang `CoKhach`; Redirect sang `order-success.jsp`. |
| **TC_ORDER_EP_02** | Controller/UI | Đặt món thất bại khi giỏ hàng rỗng | Negative | Invalid EP | Bàn: `1`<br>Giỏ hàng: Rỗng (`0 món`) | Bị chặn; Báo lỗi: *"Vui lòng chọn ít nhất 1 món để đặt"*. |
| **TC_ORDER_EP_03** | Controller/UI | Đặt món thất bại khi mã bàn không tồn tại | Negative | Invalid EP | Bàn: `99999` (Không tồn tại trong DB)<br>Món: Hợp lệ | Báo lỗi: *"Mã bàn không hợp lệ hoặc đã bị vô hiệu hóa"*. |
| **TC_ORDER_EP_04** | Controller/UI | Đặt món thất bại khi món đã hết hàng | Negative | Invalid EP | Món: `Bạc sỉu` (`trangThai = 'HetHang'`)<br>Số lượng: `1` | Báo lỗi: *"Món Bạc sỉu hiện đã hết hàng, vui lòng chọn món khác"*. |
| **TC_ORDER_EP_05** | Controller/UI | Đặt món thất bại khi số lượng là số âm | Negative | Invalid EP | Món hợp lệ<br>Số lượng: `-3` | Báo lỗi: *"Số lượng món phải là số nguyên dương"*. |
| **TC_ORDER_EP_06** | Controller/UI | Đặt món thất bại khi số lượng là số thập phân | Negative | Invalid EP | Món hợp lệ<br>Số lượng: `2.5` ly | Báo lỗi: *"Số lượng món phải là số nguyên dương"*. |
| **TC_ORDER_EP_07** | Controller/UI | Đặt món thành công khi không có ghi chú | Positive | Valid EP | Bàn: `2`<br>Món: `Trà đào` (SL: 1)<br>Ghi chú: `""` (Rỗng) | Đặt món thành công, ghi chú lưu giá trị rỗng/null hợp lệ. |

### 2. Phân Tích Giá Trị Biên (Boundary Value Analysis - BVA)

| Test Case ID | Trường kiểm thử | Ranh giới kiểm tra | Dữ liệu kiểm thử (Input) | Giá trị / Độ dài | Kết quả mong đợi |
| :---: | :--- | :---: | :--- | :---: | :--- |
| **TC_ORDER_BVA_01** | Số lượng món | Min - 1 (Invalid) | Số lượng = `0` | 0 | Báo lỗi: Số lượng đặt tối thiểu là 1. |
| **TC_ORDER_BVA_02** | Số lượng món | Min (Valid) | Số lượng = `1` ly | 1 | Hợp lệ, thêm vào đơn hàng. |
| **TC_ORDER_BVA_03** | Số lượng món | Min + 1 (Valid) | Số lượng = `2` ly | 2 | Hợp lệ. |
| **TC_ORDER_BVA_04** | Số lượng món | Max - 1 (Valid) | Số lượng = `98` ly | 98 | Hợp lệ. |
| **TC_ORDER_BVA_05** | Số lượng món | Max (Valid) | Số lượng = `99` ly | 99 | Hợp lệ (Hạn mức đặt tối đa cho 1 bàn). |
| **TC_ORDER_BVA_06** | Số lượng món | Max + 1 (Invalid) | Số lượng = `100` ly | 100 | Báo lỗi: Số lượng đặt vượt quá hạn mức tối đa (99). |
| **TC_ORDER_BVA_07** | Độ dài ghi chú | Min (Valid) | Chuỗi rỗng `""` | 0 ký tự | Hợp lệ. |
| **TC_ORDER_BVA_08** | Độ dài ghi chú | Min + 1 (Valid) | Chuỗi 1 ký tự (`"A"`) | 1 ký tự | Hợp lệ. |
| **TC_ORDER_BVA_09** | Độ dài ghi chú | Max (Valid) | Chuỗi ghi chú 200 ký tự | 200 ký tự | Hợp lệ, lưu trọn vẹn ghi chú vào đơn hàng. |
| **TC_ORDER_BVA_10** | Độ dài ghi chú | Max + 1 (Invalid) | Chuỗi ghi chú 201 ký tự | 201 ký tự | Báo lỗi: Ghi chú đồ uống không được vượt quá 200 ký tự. |

---

## PHẦN IV. MA TRẬN KIỂM THỬ TỰ ĐỘNG GIAO DIỆN (SELENIUM UI POM)

| Test Case ID | Phân hệ | Màn hình | Kịch bản tự động hóa (Selenium Actions) | Xác minh (Assertions) |
| :---: | :--- | :--- | :--- | :--- |
| **TC_UI_01** | Login | `admin/login.jsp` | 1. Mở trang login<br>2. Nhập `email = "admin@qrcoffee.com"`, `password = "admin123"`<br>3. Click nút `#btnLogin` | WebDriverWait URL chuyển sang `/admin/dashboard`; Trang quản trị hiển thị đúng lời chào Admin. |
| **TC_UI_02** | Login | `admin/login.jsp` | 1. Mở trang login<br>2. Nhập sai mật khẩu<br>3. Click `#btnLogin` | Thẻ alert xuất hiện trong DOM chứa text: *"Tài khoản hoặc mật khẩu không chính xác"*. |
| **TC_UI_03** | Drinks | `admin/drinks` | 1. Đăng nhập Admin<br>2. Vào trang `/admin/drinks`<br>3. Điền Tên: `"Trà Sữa Oolong Trân Châu"`, Giá: `40000`, Danh mục: Cà phê/Trà<br>4. Click nút "Thêm món" | Thông báo Toast thành công xuất hiện; Bảng danh sách đồ uống có thêm hàng mới chứa đúng tên và giá. |
| **TC_UI_04** | Drinks | `admin/drinks` | 1. Vào form thêm món<br>2. Nhập Giá = `0`<br>3. Click "Thêm món" | Bắt lỗi validation inline dưới ô Giá: *"Đơn giá phải lớn hơn 0"*; Không gửi request lên server. |
| **TC_UI_05** | Order | `customer/menu.jsp` | 1. Truy cập URL quét mã QR: `.../menu.jsp?table=1`<br>2. Tăng số lượng món "Cà phê sữa đá" lên 2<br>3. Nhập ghi chú: "Ít đường"<br>4. Click nút "Xác nhận đặt món" | Trình duyệt chuyển hướng sang trang `/customer/order-success.jsp`; Hiển thị đúng mã hóa đơn và tổng tiền. |
| **TC_UI_06** | Order | `customer/menu.jsp` | 1. Mở menu bàn 1<br>2. Không chọn món nào<br>3. Click nút "Xác nhận đặt món" | Modal cảnh báo hiển thị: *"Giỏ hàng của bạn đang trống"*; Nút Đặt món bị vô hiệu hóa (`disabled`). |
