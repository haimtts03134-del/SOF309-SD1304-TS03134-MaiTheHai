# Auto AI-Log Enforcement Rule (Quy Tắc Tự Động Ghi Nhật Ký Minh Chứng AI)

> **Mục tiêu:** Đảm bảo 100% các yêu cầu (prompt) và kết quả tương tác giữa sinh viên và AI đều được tự động lưu trữ đầy đủ vào thư mục `docs/ai-logs/` theo đúng thể thức chấm điểm A (Y6).

---

## 📌 TRẠNG THÁI HIỆN TẠI (STATUS)
> **Trạng thái:** ⏸️ **TẠM DỪNG GHI CHÉP (PAUSED)** theo yêu cầu của sinh viên ("các prompt lần sau không cần ghi chép lại").  
> Chỉ kích hoạt ghi nhật ký trở lại khi sinh viên có yêu cầu cụ thể (ví dụ: khi bắt đầu Tuần 2 - Y3).

---

## 📌 NGUYÊN TẮC QUY ĐỊNH (KHI ĐƯỢC KÍCH HOẠT)

Từ thời điểm này trở đi, với **BẤT KỲ YÊU CẦU NÀO** từ người dùng:
1. **Tự Động Lưu Vết Mọi Prompt:**
   - Trích dẫn chính xác câu lệnh/yêu cầu của người dùng vào file nhật ký markdown tương ứng trong thư mục `docs/ai-logs/`.
   - Nếu là giai đoạn khởi tạo & cấu hình: Ghi tiếp vào `docs/ai-logs/00_project_integration_ai.md`.
   - Nếu là thiết kế Test Plan & Test Case (Tuần 1 - Y2): Ghi vào `docs/ai-logs/01_test_design_ai.md`.
   - Nếu là viết Unit Test JUnit 5 (Tuần 2 - Y3): Ghi vào `docs/ai-logs/02_junit_script_ai.md`.
   - Nếu là viết Selenium POM (Tuần 3 & 4 - Y4): Ghi vào `docs/ai-logs/03_selenium_pom_ai.md`.
   - Nếu là xử lý lỗi / debug: Ghi vào `docs/ai-logs/04_debug_logs_ai.md`.
   - Nếu là cấu hình CI/CD GitHub Actions (Tuần 5 - Y5): Ghi vào `docs/ai-logs/05_github_actions_ai.md`.
   - Nếu là tối ưu & Code Review (Tuần 6 - Y6): Ghi vào `docs/ai-logs/06_code_review_ai.md`.

2. **Cấu Trúc Ghi Chép 4 Phần Chuẩn (Theo docs/ai-logs/README.md):**
   - **Phần 1: Ngữ cảnh & Mục tiêu** (Nêu rõ chức năng và tiêu chí cần đạt).
   - **Phần 2: Câu lệnh đã gửi cho AI (Prompt)** (Trích dẫn nguyên văn prompt).
   - **Phần 3: Quá trình & Kết quả do AI sinh ra (Raw Output)** (Code, script, hoặc cấu hình).
   - **Phần 4: Đánh giá & Chỉnh sửa của Sinh viên** (Xác nhận kiểm thử, tối ưu và lý do sửa).

3. **Cập Nhật Đồng Bộ Trước Khi Hoàn Tất Phản Hồi:**
   - Không được quên ghi chép; file log markdown phải được cập nhật ngay trong cùng lượt phản hồi của task.

---

## 🚫 NGOẠI LỆ LOẠI TRỪ (KHÔNG GHI VÀO AI-LOGS)

1. **Đặc Tả Nghiệp Vụ (Specification):**
   - **TUYỆT ĐỐI KHÔNG** ghi chép bất kỳ prompt, câu hỏi hay trao đổi nào liên quan đến việc viết, chỉnh sửa, hoàn thiện hoặc thảo luận nội dung đặc tả nghiệp vụ (`docs/SPECIFICATIONS.md`).
2. **Yêu Cầu Chỉ Định Riêng:**
   - Khi người dùng ghi chú *"không cần ghi chú/lưu prompt này"* hoặc yêu cầu tương tự, AI tuyệt đối không lưu vết vào bất kỳ file nào trong `docs/ai-logs/`.

