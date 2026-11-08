# Active Context - SOF309 Assignment

## Current Focus
- Đã hoàn thành 100% mục tiêu của **Tuần 1 (Y1 & Y2)** và đã đẩy mã nguồn an toàn lên GitHub repository: [https://github.com/haimtts03134-del/SOF309-SD1304-TS03134-MaiTheHai](https://github.com/haimtts03134-del/SOF309-SD1304-TS03134-MaiTheHai).
- Tuân thủ nghiêm ngặt rule `secret-leak-prevention`:
  - Đã cấu hình `.gitignore` chặn toàn bộ file CSDL (`*.sql`), file bảng biểu, thư mục classes (`src/main/webapp/WEB-INF/classes/`).
  - Đã ẩn danh hóa mật khẩu CSDL trong `persistence.xml` thành `${DB_PASSWORD}` trước khi commit.
  - Mã nguồn và tài liệu trên GitHub sạch 100%, không chứa secret hay PII.
- Chế độ tự động ghi log vào `ai-logs` đang **TẠM DỪNG** theo yêu cầu của sinh viên.

## Next Steps
- Tuần 2 (Y3): Viết Unit Test Controller với JUnit 5 nâng cao (`@ParameterizedTest`, `@CsvSource`, `assertThrows`) khi sinh viên sẵn sàng tiếp tục.

