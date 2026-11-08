<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.User" %>
<%@ page import="dao.UserDao" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test DB Users</title>
</head>
<body>
    <h2>Danh sách tài khoản trong cơ sở dữ liệu:</h2>
    <table border="1" cellpadding="10" style="border-collapse: collapse;">
        <tr>
            <th>Họ tên</th>
            <th>Email</th>
            <th>Mật khẩu</th>
            <th>Trạng thái</th>
            <th>Vai trò</th>
        </tr>
        <%
            try {
                UserDao dao = new UserDao();
                List<User> list = dao.findAll();
                for (User u : list) {
        %>
        <tr>
            <td><%= u.getHoTen() %></td>
            <td><strong><%= u.getEmail() %></strong></td>
            <td><%= u.getMatKhau() %></td>
            <td><%= u.getTrangThai() %></td>
            <td><%= u.getRole() != null ? u.getRole().getMaVaiTro() : "null" %></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("Lỗi truy vấn DB: " + e.getMessage());
                e.printStackTrace(new java.io.PrintWriter(out));
            }
        %>
    </table>
</body>
</html>
