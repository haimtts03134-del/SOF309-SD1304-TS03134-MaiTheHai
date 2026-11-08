package controller.admin;

import dao.CustomerDao;
import entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý các chức năng Thêm, Sửa, Xóa, Hiển thị (CRUD) cho đối tượng Khách hàng.
 */
@WebServlet("/admin/customers")
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CustomerDao customerDao;

    @Override
    public void init() throws ServletException {
        customerDao = new CustomerDao();
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
                    deleteCustomer(request, response);
                    break;
                case "list":
                default:
                    listCustomers(request, response);
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
                    insertCustomer(request, response);
                    break;
                case "update":
                    updateCustomer(request, response);
                    break;
                default:
                    listCustomers(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // Hiển thị danh sách khách hàng
    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Customer> customers = customerDao.findAll();
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
    }

    // Đổ dữ liệu khách hàng cần sửa lên Form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Customer existingCustomer = customerDao.findById(id);

        List<Customer> customers = customerDao.findAll();
        request.setAttribute("customers", customers);
        request.setAttribute("selectedCustomer", existingCustomer);
        request.setAttribute("isEdit", true); // Đánh dấu đang chỉnh sửa

        request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
    }

    // Thêm mới khách hàng
    private void insertCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String hoTen = request.getParameter("hoTen");
        String soDienThoai = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String diemStr = request.getParameter("diemTichLuy");
        String trangThai = request.getParameter("trangThai");

        if (email != null && email.trim().isEmpty()) {
            email = null;
        }

        int diemTichLuy = 0;
        if (diemStr != null && !diemStr.trim().isEmpty()) {
            diemTichLuy = Integer.parseInt(diemStr);
        }

        Customer newCustomer = new Customer(hoTen, soDienThoai, email, diemTichLuy, trangThai);

        try {
            // Validation bổ sung: Kiểm tra định dạng số điện thoại (10 chữ số bắt đầu bằng 03, 05, 07, 08, 09)
            if (soDienThoai == null || !soDienThoai.trim().matches("^(03|05|07|08|09)\\d{8}$")) {
                throw new Exception("Số điện thoại không hợp lệ! Vui lòng nhập 10 chữ số bắt đầu bằng các đầu số 03, 05, 07, 08 hoặc 09 (Ví dụ: 0912345678, 0381234567).");
            }

            // Validation bổ sung: check trùng số điện thoại
            Customer checkPhone = customerDao.findByPhone(soDienThoai.trim());
            if (checkPhone != null) {
                throw new Exception("Số điện thoại này đã được đăng ký bởi khách hàng khác!");
            }

            // Check trùng email nếu có nhập email
            if (email != null && !email.trim().isEmpty()) {
                Customer checkEmail = customerDao.findByEmail(email);
                if (checkEmail != null) {
                    throw new Exception("Email này đã được đăng ký bởi khách hàng khác!");
                }
            }

            customerDao.create(newCustomer);
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        } catch (Exception ex) {
            String detailMessage = ex.getMessage();
            Throwable cause = ex.getCause();
            while (cause != null) {
                detailMessage = cause.getMessage();
                cause = cause.getCause();
            }

            request.setAttribute("errorMessage", detailMessage);
            request.setAttribute("selectedCustomer", newCustomer);
            
            List<Customer> customers = customerDao.findAll();
            request.setAttribute("customers", customers);

            request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
        }
    }

    // Cập nhật thông tin khách hàng
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String hoTen = request.getParameter("hoTen");
        String soDienThoai = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String diemStr = request.getParameter("diemTichLuy");
        String trangThai = request.getParameter("trangThai");

        if (email != null && email.trim().isEmpty()) {
            email = null;
        }

        int diemTichLuy = 0;
        if (diemStr != null && !diemStr.trim().isEmpty()) {
            diemTichLuy = Integer.parseInt(diemStr);
        }

        Customer customer = customerDao.findById(id);
        if (customer != null) {
            customer.setHoTen(hoTen);
            customer.setSoDienThoai(soDienThoai);
            customer.setEmail(email);
            customer.setDiemTichLuy(diemTichLuy);
            customer.setTrangThai(trangThai);

            try {
                // Validation bổ sung: Kiểm tra định dạng số điện thoại (10 chữ số bắt đầu bằng 03, 05, 07, 08, 09)
                if (soDienThoai == null || !soDienThoai.trim().matches("^(03|05|07|08|09)\\d{8}$")) {
                    throw new Exception("Số điện thoại không hợp lệ! Vui lòng nhập 10 chữ số bắt đầu bằng các đầu số 03, 05, 07, 08 hoặc 09 (Ví dụ: 0912345678, 0381234567).");
                }

                // Validation bổ sung: check trùng số điện thoại (trừ chính nó)
                Customer checkPhone = customerDao.findByPhone(soDienThoai.trim());
                if (checkPhone != null && checkPhone.getMaKhachHang() != id) {
                    throw new Exception("Số điện thoại này đã được đăng ký bởi khách hàng khác!");
                }

                // Check trùng email (trừ chính nó)
                if (email != null && !email.trim().isEmpty()) {
                    Customer checkEmail = customerDao.findByEmail(email);
                    if (checkEmail != null && checkEmail.getMaKhachHang() != id) {
                        throw new Exception("Email này đã được đăng ký bởi khách hàng khác!");
                    }
                }

                customerDao.update(customer);
                response.sendRedirect(request.getContextPath() + "/admin/customers");
            } catch (Exception ex) {
                String detailMessage = ex.getMessage();
                Throwable cause = ex.getCause();
                while (cause != null) {
                    detailMessage = cause.getMessage();
                    cause = cause.getCause();
                }

                request.setAttribute("errorMessage", detailMessage);
                request.setAttribute("selectedCustomer", customer);
                request.setAttribute("isEdit", true);

                List<Customer> customers = customerDao.findAll();
                request.setAttribute("customers", customers);

                request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }

    // Xóa khách hàng
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            customerDao.delete(id);
        } catch (Exception ex) {
            // Có thể ghi log lỗi
        }
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }
}
