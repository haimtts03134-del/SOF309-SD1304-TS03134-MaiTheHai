package controller.admin;

import dao.RoleDao;
import dao.UserDao;
import entity.Role;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý các chức năng Thêm, Sửa, Xóa, Hiển thị (CRUD) cho đối tượng Nhân viên (Users / NguoiDung).
 */
@WebServlet("/admin/employees")
public class EmployeeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDao userDao;
    private RoleDao roleDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDao();
        roleDao = new RoleDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteEmployee(request, response);
                    break;
                case "list":
                default:
                    listEmployees(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "insert";
        }

        try {
            switch (action) {
                case "insert":
                    insertEmployee(request, response);
                    break;
                case "update":
                    updateEmployee(request, response);
                    break;
                default:
                    listEmployees(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // Hiển thị danh sách nhân viên
    private void listEmployees(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> employees = userDao.findAll();
        List<Role> roles = roleDao.findAll();
        
        request.setAttribute("employees", employees);
        request.setAttribute("roles", roles);
        
        request.getRequestDispatcher("/admin/employees.jsp").forward(request, response);
    }

    // Đổ dữ liệu nhân viên cần sửa lên Form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        User existingUser = userDao.findById(id);
        
        List<User> employees = userDao.findAll();
        List<Role> roles = roleDao.findAll();

        request.setAttribute("employees", employees);
        request.setAttribute("roles", roles);
        request.setAttribute("selectedEmployee", existingUser);
        request.setAttribute("isEdit", true); // Đánh dấu là đang ở chế độ chỉnh sửa

        request.getRequestDispatcher("/admin/employees.jsp").forward(request, response);
    }

    // Thêm mới nhân viên
    private void insertEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String hoTen = request.getParameter("hoTen");
        String email = request.getParameter("email");
        String soDienThoai = request.getParameter("soDienThoai");
        String matKhau = request.getParameter("matKhau");
        String hinhAnh = request.getParameter("hinhAnh");
        String trangThai = request.getParameter("trangThai");
        String maVaiTro = request.getParameter("maVaiTro");

        Role role = roleDao.findById(maVaiTro);
        User newUser = new User(hoTen, email, soDienThoai, matKhau, trangThai, role);
        newUser.setHinhAnh(hinhAnh);

        try {
            userDao.create(newUser);
            response.sendRedirect(request.getContextPath() + "/admin/employees");
        } catch (Exception ex) {
            // Lấy nguyên nhân chi tiết nhất của lỗi (ví dụ: lỗi Unique constraint của DB)
            String detailMessage = ex.getMessage();
            Throwable cause = ex.getCause();
            while (cause != null) {
                detailMessage = cause.getMessage();
                cause = cause.getCause();
            }

            request.setAttribute("errorMessage", detailMessage);
            request.setAttribute("selectedEmployee", newUser);
            
            List<User> employees = userDao.findAll();
            List<Role> roles = roleDao.findAll();
            request.setAttribute("employees", employees);
            request.setAttribute("roles", roles);
            
            request.getRequestDispatcher("/admin/employees.jsp").forward(request, response);
        }
    }

    // Cập nhật thông tin nhân viên
    private void updateEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String hoTen = request.getParameter("hoTen");
        String email = request.getParameter("email");
        String soDienThoai = request.getParameter("soDienThoai");
        String matKhau = request.getParameter("matKhau");
        String hinhAnh = request.getParameter("hinhAnh");
        String trangThai = request.getParameter("trangThai");
        String maVaiTro = request.getParameter("maVaiTro");

        Role role = roleDao.findById(maVaiTro);
        User user = userDao.findById(id);
        
        if (user != null) {
            user.setHoTen(hoTen);
            user.setEmail(email);
            user.setSoDienThoai(soDienThoai);
            if (matKhau != null && !matKhau.trim().isEmpty()) {
                user.setMatKhau(matKhau);
            }
            user.setHinhAnh(hinhAnh);
            user.setTrangThai(trangThai);
            user.setRole(role);
            
            try {
                userDao.update(user);
                response.sendRedirect(request.getContextPath() + "/admin/employees");
            } catch (Exception ex) {
                // Lấy nguyên nhân chi tiết nhất của lỗi
                String detailMessage = ex.getMessage();
                Throwable cause = ex.getCause();
                while (cause != null) {
                    detailMessage = cause.getMessage();
                    cause = cause.getCause();
                }

                request.setAttribute("errorMessage", detailMessage);
                request.setAttribute("selectedEmployee", user);
                request.setAttribute("isEdit", true);
                
                List<User> employees = userDao.findAll();
                List<Role> roles = roleDao.findAll();
                request.setAttribute("employees", employees);
                request.setAttribute("roles", roles);
                
                request.getRequestDispatcher("/admin/employees.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/employees");
        }
    }

    // Xóa nhân viên
    private void deleteEmployee(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        userDao.delete(id);
        response.sendRedirect(request.getContextPath() + "/admin/employees");
    }
}
