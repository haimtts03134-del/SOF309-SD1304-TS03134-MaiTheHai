# SOF309: KIỂM THỬ NÂNG CAO CÙNG AI
> **Template Assignment cho Sinh viên FPT Polytechnic**  
> Giảng viên: **Thầy Trần Quang Bình (binhtq7)**

---

## 📌 HƯỚNG DẪN BẮT ĐẦU DÀNH CHO SINH VIÊN

1. Bấm nút **Use this template** (hoặc Fork) để tạo Repository bài làm của riêng bạn.
2. Đặt tên Repo theo cú pháp:
   > `SOF309_<MÃ_LỚP>_<MSSV>_<HọVàTên>` *(Ví dụ: `SOF309_SD21307_PD12345_NguyenVanA`)*
3. Tạo **GitHub Project (Kanban Board)** trên Repo cá nhân để quản lý tiến độ 6 tuần.
4. Đưa source code Web cá nhân vào thư mục `src/main/` và bắt đầu viết test vào `src/test/`.
5. Nộp link Repo cá nhân lên **Google Classroom** của lớp.

---

## 📁 CẤU TRÚC THƯ MỤC NỘP BÀI

```text
SOF309_<MÃ_LỚP>_<MSSV>_<HoTen>/
├── .github/
│   └── workflows/
│       └── test.yml             # [Y5] Tự động chạy test khi push code
├── docs/                        # [Y2 & Y6] Tài liệu & Minh chứng AI
│   ├── SPECIFICATIONS.md        # [Y1] Đặc tả nghiệp vụ Web cá nhân
│   ├── TEST_PLAN.md             # [Y2] Kế hoạch kiểm thử
│   ├── TEST_CASES.md            # [Y2] Bộ kịch bản Test Case chi tiết
│   └── ai-logs/                 # [Y6] Minh chứng sử dụng AI (Bắt buộc để đạt điểm A)
│       └── README.md
├── src/
│   ├── main/                    # [Y1] Source code Web cá nhân chạy được
│   └── test/                    # [Y3, Y4] Mã nguồn kiểm thử (JUnit, TestNG, Selenium POM)
├── .gitignore
└── README.md
```

---

## 🎯 6 YÊU CẦU ASSIGNMENT (Y1 - Y6)

* **Y1:** Web cá nhân chạy được local (có Đăng ký, Đăng nhập, CRUD 1 chức năng).
* **Y2:** Thiết kế Test Plan & Test Case (dùng AI + RAG theo `SPECIFICATIONS.md`).
* **Y3:** Cài JUnit, viết Unit Test cho Controller.
* **Y4:** Cài Selenium WebDriver, viết test UI tự động theo mô hình Page Object Model (POM).
* **Y5:** Đẩy code lên GitHub, cấu hình GitHub Actions CI/CD chạy pass.
* **Y6 (Điểm A):** Lưu đầy đủ minh chứng tương tác AI trong thư mục `docs/ai-logs/`.
