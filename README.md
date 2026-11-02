# SOF309: KIỂM THỬ NÂNG CAO CÙNG AI
> **Master Template Assignment dành cho Sinh viên FPT Polytechnic**  
> Giảng viên: **Thầy Trần Quang Bình (binhtq7)**

---

## 🚀 HƯỚNG DẪN 5 BƯỚC TÍCH HỢP WEB CÓ SẴN VÀO REPO (CÁCH 1)

Dự án này là khung chuẩn (Template) chứa sẵn cấu trúc kiểm thử, CI/CD và tài liệu. Sinh viên lấy code Web đã làm từ kỳ trước để tích hợp vào theo các bước sau:

### 🔹 Bước 1: Tạo Repo cá nhân từ Template của Thầy
1. Bấm nút xanh **Use this template** (ở góc trên bên phải trang này) $\rightarrow$ chọn **Create a new repository**.
2. Đặt tên Repository theo đúng quy chuẩn:
   > `SOF309_<MÃ_LỚP>_<MSSV>_<HọVàTên>`  
   *(Ví dụ: `SOF309_SD21307_PD12345_NguyenVanA`)*
3. Chọn chế độ **Public** và bấm **Create repository**.

### 🔹 Bước 2: Clone về máy tính
Mở Terminal / Git Bash và gõ:
```bash
git clone https://github.com/<tai-khoan-cua-ban>/SOF309_<MÃ_LỚP>_<MSSV>_<HoTen>.git
```

### 🔹 Bước 3: Đưa Source Web cũ vào dự án
1. Mở thư mục dự án vừa clone.
2. **Copy toàn bộ code Web cũ** của bạn (các package Controller, Service, Model, View/HTML...) dán vào thư mục `src/main/java/` và `src/main/resources/`.
3. Mở file `pom.xml`, dán thêm các thư viện cần thiết của web cũ (Spring Boot, MySQL, Thymeleaf...) vào mục `<dependencies>`. File `pom.xml` của Thầy đã cấu hình sẵn **JUnit 5** và **Selenium WebDriver**.
4. Chạy thử web ở local (`http://localhost:8080`) để đảm bảo Web vẫn chạy mượt mà (**Xong Y1**).

### 🔹 Bước 4: Viết Test Script & Tài liệu
1. **[Y2] Kế hoạch & Kịch bản Test:** Mở thư mục `docs/` để điền đặc tả `SPECIFICATIONS.md`, kế hoạch `TEST_PLAN.md` và bảng `TEST_CASES.md`.
2. **[Y3] Viết JUnit Test:** Viết các class test cho Controller trong `src/test/java/.../controllers/` (xem file mẫu `SampleControllerTest.java`).
3. **[Y4] Viết Selenium UI Test:** Viết các class Page Object trong `src/test/java/.../ui/pages/` và kịch bản test trong `src/test/java/.../ui/tests/` (xem file mẫu `LoginPage.java` và `LoginTest.java`).
4. **[Y6] Lưu minh chứng AI (Điểm A):** Ghi chép câu lệnh (prompt), code AI sinh và code bạn tự sửa vào các file trong thư mục `docs/ai-logs/`.

### 🔹 Bước 5: Đẩy bài lên GitHub & Nộp link
```bash
git add .
git commit -m "feat: complete assignment automation tests"
git push origin main
```
* Kiểm tra tab **Actions** trên GitHub: Pipeline tự động chạy và sáng đèn **Xanh (Pass)** (**Xong Y5**).
* Nộp đường link GitHub Repo của bạn vào **Google Classroom** của lớp.

---

## 📁 CẤU TRÚC THƯ MỤC CHUẨN CỦA DỰ ÁN

```text
SOF309_<MÃ_LỚP>_<MSSV>_<HoTen>/
├── pom.xml                               # Đã tích hợp sẵn JUnit 5 & Selenium
├── .github/
│   └── workflows/
│       └── test.yml                     # [Y5] Tự động chạy test khi push code
├── docs/                                # [Y2 & Y6] Tài liệu & Minh chứng AI
│   ├── SPECIFICATIONS.md                # [Y1] Đặc tả nghiệp vụ Web cá nhân
│   ├── TEST_PLAN.md                     # [Y2] Kế hoạch kiểm thử
│   ├── TEST_CASES.md                    # [Y2] Bộ kịch bản Test Case chi tiết
│   └── ai-logs/                         # [Y6] Minh chứng tương tác AI (Điểm A)
│       └── README.md
├── src/
│   ├── main/                            # [Y1] Source code Web cá nhân của sinh viên
│   │   ├── java/
│   │   └── resources/
│   └── test/java/com/poly/sof309/
│       ├── controllers/                 # [Y3] Viết JUnit Test Script cho Controller
│       │   └── SampleControllerTest.java
│       └── ui/                          # [Y4] Viết Selenium Test (Page Object Model)
│           ├── pages/                   # Các class Page Object (LoginPage.java...)
│           │   └── LoginPage.java
│           └── tests/                   # Kịch bản test chạy trên trình duyệt
│               └── LoginTest.java
├── .gitignore
└── README.md
```

---

## 🎯 6 YÊU CẦU ĐÁNH GIÁ (Y1 - Y6)

* **Y1:** Web cá nhân chạy được local (có Đăng ký, Đăng nhập, CRUD 1 chức năng).
* **Y2:** Thiết kế Test Plan & Test Case (dùng AI + RAG theo `SPECIFICATIONS.md`).
* **Y3:** Cài JUnit, viết Unit Test cho Controller (`mvn test` pass 100%).
* **Y4:** Cài Selenium WebDriver, viết test UI tự động theo mô hình Page Object Model (POM).
* **Y5:** Đẩy code lên GitHub, cấu hình GitHub Actions CI/CD chạy pass màu xanh.
* **Y6 (Điểm A):** Lưu đầy đủ minh chứng tương tác AI trong thư mục `docs/ai-logs/`.
