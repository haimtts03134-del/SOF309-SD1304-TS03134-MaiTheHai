package controller.staff;

import dao.OrderDao;
import dao.UserDao;
import entity.Order;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý danh sách đơn hàng dành cho Nhân viên (Staff Order Management).
 * Tối ưu hóa cập nhật trạng thái nhanh bằng AJAX và nạp dữ liệu siêu tốc.
 */
@WebServlet("/staff/orders")
public class StaffOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private UserDao userDao;

    @Override
    public void init() throws ServletException {
        orderDao = new OrderDao();
        userDao = new UserDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        // Xử lý yêu cầu Ping ngầm (Heartbeat) để giữ session
        if ("ping".equals(action)) {
            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("pong");
            return;
        } else if ("load-more".equals(action)) {
            loadMoreStaffOrders(request, response);
            return;
        }

        // Tự động kiểm tra & điểm danh vào ca bảo vệ ngày công cho nhân viên khi truy cập trang quản lý đơn
        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                String employeeEmail = (String) session.getAttribute("staffUser");
                if (employeeEmail == null) employeeEmail = (String) session.getAttribute("adminEmail");
                if (employeeEmail != null) {
                    User loggedUser = userDao.findByEmail(employeeEmail);
                    if (loggedUser != null) {
                        dao.AttendanceDao attendanceDao = new dao.AttendanceDao();
                        java.util.Date today = new java.util.Date();
                        attendanceDao.autoCheckoutExpiredShifts(today);

                        // Nếu đã kết thúc ca làm hôm nay (và không có ca đang mở), đăng xuất an toàn để bàn giao ca
                        entity.Attendance activeShift = attendanceDao.findActiveShiftByUser(loggedUser.getMaNguoiDung(), today);
                        entity.Attendance todayCompleted = attendanceDao.findByUserAndDate(loggedUser.getMaNguoiDung(), today);
                        if (activeShift == null && todayCompleted != null && todayCompleted.getGioRa() != null) {
                            session.invalidate();
                            String msg = "Bạn đã kết thúc ca làm hôm nay. Tài khoản đã được đăng xuất an toàn để bàn giao ca!";
                            response.sendRedirect(request.getContextPath() + "/admin/login?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
                            return;
                        }

                        String autoMsg = attendanceDao.autoCheckInOnLogin(loggedUser, today);
                        if (autoMsg != null && session.getAttribute("orderSuccess") == null) {
                            session.setAttribute("orderSuccess", autoMsg);
                        }
                    }
                }
            }
        } catch (Exception ignored) {}

        // Lấy bộ lọc trạng thái từ request parameter
        String statusFilter = request.getParameter("status"); // ChoThanhToan, DangCheBien, DaGiao, DaThanhToan, DaHuy

        List<Order> displayedOrders;
        long totalCount = 0;
        int initialLimit = 15;

        if (statusFilter == null || statusFilter.trim().isEmpty() || "Active".equals(statusFilter)) {
            displayedOrders = orderDao.findActiveOrders(0, initialLimit);
            totalCount = orderDao.countActiveOrders();
            request.setAttribute("currentTab", "active");
        } else if ("All".equals(statusFilter)) {
            displayedOrders = orderDao.findAll(0, initialLimit);
            totalCount = orderDao.countAll();
            request.setAttribute("currentTab", "all");
        } else if ("ChoThanhToan".equals(statusFilter)) {
            displayedOrders = orderDao.findPendingPaymentOrders(0, initialLimit);
            totalCount = orderDao.countPendingPaymentOrders();
            request.setAttribute("currentTab", "ChoThanhToan");
        } else {
            displayedOrders = orderDao.findByStatus(statusFilter, 0, initialLimit);
            totalCount = orderDao.countByStatus(statusFilter);
            request.setAttribute("currentTab", statusFilter);
        }

        boolean hasMore = totalCount > displayedOrders.size();

        // Gửi dữ liệu sang trang JSP
        request.setAttribute("orders", displayedOrders);
        request.setAttribute("displayedCount", displayedOrders.size());
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("hasMore", hasMore);
        request.setAttribute("initialLimit", initialLimit);
        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "Active");

        request.getRequestDispatcher("/staff/orders.jsp").forward(request, response);
    }

    private void loadMoreStaffOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");

        int offset = 0;
        int limit = 15;
        try {
            if (request.getParameter("offset") != null) offset = Integer.parseInt(request.getParameter("offset"));
            if (request.getParameter("limit") != null) limit = Integer.parseInt(request.getParameter("limit"));
        } catch (Exception ignored) {}

        String statusFilter = request.getParameter("status");
        List<Order> orders;
        long totalCount = 0;

        if (statusFilter == null || statusFilter.trim().isEmpty() || "Active".equals(statusFilter)) {
            orders = orderDao.findActiveOrders(offset, limit);
            totalCount = orderDao.countActiveOrders();
        } else if ("All".equals(statusFilter)) {
            orders = orderDao.findAll(offset, limit);
            totalCount = orderDao.countAll();
        } else if ("ChoThanhToan".equals(statusFilter)) {
            orders = orderDao.findPendingPaymentOrders(offset, limit);
            totalCount = orderDao.countPendingPaymentOrders();
        } else {
            orders = orderDao.findByStatus(statusFilter, offset, limit);
            totalCount = orderDao.countByStatus(statusFilter);
        }

        java.text.SimpleDateFormat sdfFull = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        java.text.NumberFormat currencyFmt = java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("vi", "VN"));

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"offset\":").append(offset).append(",");
        json.append("\"limit\":").append(limit).append(",");
        json.append("\"totalCount\":").append(totalCount).append(",");
        json.append("\"loadedCount\":").append(offset + orders.size()).append(",");
        json.append("\"hasMore\":").append((offset + orders.size()) < totalCount).append(",");
        json.append("\"orders\":[");

        for (int i = 0; i < orders.size(); i++) {
            Order o = orders.get(i);
            if (i > 0) json.append(",");

            String customerName = o.getCustomer() != null ? o.getCustomer().getHoTen() : "Khách vãng lai";
            String customerPhone = o.getCustomer() != null ? o.getCustomer().getSoDienThoai() : "";
            String tableName = o.getTable() != null ? o.getTable().getTenBan() : "Mang về";
            String staffName = o.getUser() != null ? o.getUser().getHoTen() : "Hệ thống";

            StringBuilder itemsHtml = new StringBuilder();
            StringBuilder itemsSummary = new StringBuilder();
            if (o.getOrderDetails() != null) {
                for (int dIdx = 0; dIdx < o.getOrderDetails().size(); dIdx++) {
                    entity.OrderDetail d = o.getOrderDetails().get(dIdx);
                    String drinkName = d.getDrink() != null ? d.getDrink().getTenSanPham() : "N/A";
                    
                    if (dIdx > 0) itemsSummary.append(", ");
                    itemsSummary.append(d.getSoLuong()).append("x ").append(drinkName);

                    itemsHtml.append("<div class='d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom'>")
                             .append("<div>")
                             .append("<div class='fw-bold text-dark'>").append(escapeJson(drinkName)).append("</div>")
                             .append("<small class='text-muted'>").append((long)d.getDonGia()).append(" đ x ").append(d.getSoLuong()).append("</small>");
                    if (d.getGhiChu() != null && !d.getGhiChu().isEmpty()) {
                        itemsHtml.append("<br><small class='text-danger fst-italic'>Note: ").append(escapeJson(d.getGhiChu())).append("</small>");
                    }
                    itemsHtml.append("</div>")
                             .append("<span class='fw-bold text-dark'>").append((long)(d.getDonGia() * d.getSoLuong())).append(" đ</span>")
                             .append("</div>");
                }
            }

            json.append("{");
            json.append("\"id\":").append(o.getMaHoaDon()).append(",");
            json.append("\"dateStr\":\"").append(sdfFull.format(o.getNgayTao())).append("\",");
            json.append("\"type\":\"").append(escapeJson(o.getLoaiHoaDon())).append("\",");
            json.append("\"tableName\":\"").append(escapeJson(tableName)).append("\",");
            json.append("\"customerName\":\"").append(escapeJson(customerName)).append("\",");
            json.append("\"customerPhone\":\"").append(escapeJson(customerPhone)).append("\",");
            json.append("\"staffName\":\"").append(escapeJson(staffName)).append("\",");
            json.append("\"total\":").append((long)o.getTongTien()).append(",");
            json.append("\"formattedTotal\":\"").append(escapeJson(currencyFmt.format(o.getTongTien()))).append("\",");
            json.append("\"status\":\"").append(escapeJson(o.getTrangThai())).append("\",");
            json.append("\"note\":\"").append(escapeJson(o.getGhiChu())).append("\",");
            json.append("\"itemsSummary\":\"").append(escapeJson(itemsSummary.toString())).append("\",");
            json.append("\"itemsHtml\":\"").append(escapeJson(itemsHtml.toString())).append("\"");
            json.append("}");
        }

        json.append("]}");

        java.io.PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (ch < ' ') {
                        String hex = Integer.toHexString(ch);
                        sb.append("\\u");
                        for (int k = 0; k < 4 - hex.length(); k++) sb.append('0');
                        sb.append(hex);
                    } else {
                        sb.append(ch);
                    }
            }
        }
        return sb.toString();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String action = request.getParameter("action");
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With")) || 
                         "true".equalsIgnoreCase(request.getParameter("isAjax"));
        
        if ("update-status".equals(action)) {
            String idStr = request.getParameter("id");
            String status = request.getParameter("status");
            String cancelReason = request.getParameter("cancelReason");

            boolean updateSuccess = false;
            String message = "";

            if (idStr != null && status != null) {
                try {
                    int orderId = Integer.parseInt(idStr);
                    Order order = orderDao.findById(orderId);

                    if (order != null) {
                        String oldStatus = order.getTrangThai();
                        
                        // Cập nhật trạng thái mới
                        order.setTrangThai(status);

                        // Lưu lý do hủy đơn nếu có (giới hạn tối đa 250 ký tự để tránh lỗi CSDL column length)
                        if ("DaHuy".equals(status) && cancelReason != null && !cancelReason.trim().isEmpty()) {
                            String existingNote = order.getGhiChu() != null ? order.getGhiChu() : "";
                            String newNote = "[Lý do hủy: " + cancelReason.trim() + "] " + existingNote;
                            if (newNote.length() > 250) {
                                newNote = newNote.substring(0, 247) + "...";
                            }
                            order.setGhiChu(newNote);
                        }

                        // Gán nhân viên xử lý hiện tại nếu đơn hàng chưa có nhân viên hoặc khi nhân viên đổi trạng thái
                        String employeeEmail = (String) session.getAttribute("staffUser");
                        if (employeeEmail == null) employeeEmail = (String) session.getAttribute("adminEmail");
                        if (employeeEmail == null) employeeEmail = (String) session.getAttribute("adminUser");
                        if (employeeEmail != null) {
                            User currentUser = userDao.findByEmail(employeeEmail);
                            if (currentUser != null) {
                                order.setUser(currentUser);
                            }
                        }

                        // Xử lý khấu trừ điểm tích lũy nếu đơn bị hủy
                        if ("DaHuy".equals(status) && !"DaHuy".equals(oldStatus)) {
                            entity.Customer customer = order.getCustomer();
                            if (customer != null) {
                                int pointsToDeduct = (int) (order.getTongTien() / 10000);
                                int currentPoints = customer.getDiemTichLuy();
                                customer.setDiemTichLuy(Math.max(0, currentPoints - pointsToDeduct));
                                new dao.CustomerDao().update(customer);
                            }
                        }

                        orderDao.update(order);
                        updateSuccess = true;
                        message = "Đã cập nhật trạng thái đơn hàng #" + orderId + " thành công!";
                        session.setAttribute("orderSuccess", message);
                    } else {
                        message = "Không tìm thấy đơn hàng #" + orderId;
                        session.setAttribute("orderError", message);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    message = "Có lỗi xảy ra khi lưu: " + (e.getMessage() != null ? e.getMessage() : e.toString());
                    session.setAttribute("orderError", message);
                }
            }

            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":" + updateSuccess + ",\"message\":\"" + escapeJson(message) + "\"}");
                return;
            }
        }

        // Quay lại trang danh sách đơn hàng
        String status = request.getParameter("status");
        if ("DaThanhToan".equals(status)) {
            response.sendRedirect(request.getContextPath() + "/staff/orders?status=DaThanhToan");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/orders");
        }
    }
}
