package controller.staff;

import dao.CustomerDao;
import dao.OrderDao;
import dao.UserDao;
import entity.Customer;
import entity.Order;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet xử lý chi tiết đơn hàng dành riêng cho nhân viên.
 * Cho phép xem chi tiết, xác nhận thanh toán hoặc hủy đơn hàng.
 */
@WebServlet("/staff/orders/detail")
public class StaffOrderDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private UserDao userDao;
    private CustomerDao customerDao;

    @Override
    public void init() throws ServletException {
        orderDao = new OrderDao();
        userDao = new UserDao();
        customerDao = new CustomerDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr.trim());
            Order order = orderDao.findById(orderId);

            if (order != null) {
                request.setAttribute("order", order);
                request.getRequestDispatcher("/staff/order-detail.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("orderError", "Không tìm thấy đơn hàng #" + orderId);
                response.sendRedirect(request.getContextPath() + "/staff/orders");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/staff/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String idStr = request.getParameter("id");
        String status = request.getParameter("status");
        String note = request.getParameter("note");

        if (idStr != null && status != null) {
            try {
                int orderId = Integer.parseInt(idStr.trim());
                Order order = orderDao.findById(orderId);

                if (order != null) {
                    String oldStatus = order.getTrangThai();
                    
                    // Cập nhật trạng thái
                    order.setTrangThai(status);
                    
                    // Cập nhật ghi chú của nhân viên nếu có
                    if (note != null) {
                        order.setGhiChu(note.trim());
                    }

                    // Gán nhân viên xử lý hiện tại
                    String employeeEmail = (String) session.getAttribute("staffUser");
                    if (employeeEmail == null) employeeEmail = (String) session.getAttribute("adminEmail");
                    if (employeeEmail == null) employeeEmail = (String) session.getAttribute("adminUser");
                    if (employeeEmail != null) {
                        User currentUser = userDao.findByEmail(employeeEmail);
                        if (currentUser != null) {
                            order.setUser(currentUser);
                        }
                    }

                    // Xử lý hoàn điểm tích lũy khi hủy đơn hàng
                    if ("DaHuy".equals(status) && !"DaHuy".equals(oldStatus)) {
                        Customer customer = order.getCustomer();
                        if (customer != null) {
                            int pointsToDeduct = (int) (order.getTongTien() / 10000);
                            int currentPoints = customer.getDiemTichLuy();
                            customer.setDiemTichLuy(Math.max(0, currentPoints - pointsToDeduct));
                            customerDao.update(customer);
                        }
                    }

                    orderDao.update(order);
                    session.setAttribute("orderSuccess", "Đã cập nhật đơn hàng #" + orderId + " thành công!");
                    
                    // Chuyển hướng lại trang danh sách đơn hàng hoặc chi tiết đơn hàng
                    if ("DaThanhToan".equals(status)) {
                        response.sendRedirect(request.getContextPath() + "/staff/orders?status=DaThanhToan");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/staff/orders/detail?id=" + orderId);
                    }
                    return;
                } else {
                    session.setAttribute("orderError", "Không tìm thấy đơn hàng #" + orderId);
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("orderError", "Có lỗi xảy ra: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/staff/orders");
    }
}
