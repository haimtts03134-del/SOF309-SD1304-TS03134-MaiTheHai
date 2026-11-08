<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.User" %>
<%@ page import="dao.UserDao" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tra cứu tài khoản hệ thống (Không cần đăng nhập)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light py-5">
    <div class="container">
        <div class="card border-0 shadow" style="border-radius: 15px;">
            <div class="card-header bg-dark text-white text-center py-3" style="border-radius: 15px 15px 0 0;">
                <h4 class="mb-0 fw-bold">Danh Sách Tài Khoản Trong Cơ Sở Dữ Liệu</h4>
                <small class="text-secondary">Dùng để tra cứu nhanh thông tin email, mật khẩu và trạng thái thực tế trong DB</small>
            </div>
            <div class="card-body p-4">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th>Họ Tên</th>
                                <th>Email đăng nhập (Chính xác trong DB)</th>
                                <th>Mật khẩu</th>
                                <th>Trạng thái thực tế</th>
                                <th>Vai trò</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    UserDao dao = new UserDao();
                                    List<User> list = dao.findAll();
                                    for (User u : list) {
                            %>
                            <tr>
                                <td><%= u.getHoTen() %></td>
                                <td><code class="fs-5 text-primary fw-bold"><%= u.getEmail() %></code></td>
                                <td><code><%= u.getMatKhau() %></code></td>
                                <td>
                                    <% if ("HoatDong".equals(u.getTrangThai())) { %>
                                        <span class="badge bg-success">Hoạt Động</span>
                                    <% } else { %>
                                        <span class="badge bg-danger">Bị Khóa (<%= u.getTrangThai() %>)</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge bg-secondary"><%= u.getRole() != null ? u.getRole().getMaVaiTro() : "N/A" %></span>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                            %>
                            <tr>
                                <td colspan="5" class="text-danger">
                                    <strong>Lỗi kết nối CSDL:</strong> <%= e.getMessage() %>
                                    <pre class="mt-2 text-dark" style="font-size: 0.8rem;"><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
                <div class="alert alert-info mt-3 mb-0">
                    <i class="bi bi-info-circle-fill me-2"></i><strong>Lưu ý:</strong> Hãy copy chính xác email hiển thị màu xanh ở bảng trên dán vào ô đăng nhập.
                </div>
            </div>
        </div>
    </div>
</body>
</html>
