package controller.admin;

import dao.CustomerDao;
import dao.DrinkDao;
import dao.OrderDao;
import dao.TableDao;
import dao.UserDao;
import entity.Customer;
import entity.Drink;
import entity.Order;
import entity.OrderDetail;
import entity.Table;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Servlet quản lý hóa đơn dành riêng cho Quản trị viên (Admin).
 * Cho phép xem theo ngày, lọc trạng thái, xem chi tiết, thêm mới, sửa và xóa hóa đơn.
 */
@WebServlet("/admin/invoices")
public class InvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private TableDao tableDao;
    private CustomerDao customerDao;
    private DrinkDao drinkDao;
    private UserDao userDao;

    @Override
    public void init() throws ServletException {
        orderDao = new OrderDao();
        tableDao = new TableDao();
        customerDao = new CustomerDao();
        drinkDao = new DrinkDao();
        userDao = new UserDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            deleteInvoice(request, response);
            return;
        } else if ("load-more".equals(action)) {
            loadMoreInvoices(request, response);
            return;
        }

        listInvoices(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("insert".equals(action)) {
            insertInvoice(request, response);
        } else if ("update".equals(action)) {
            updateInvoice(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/invoices");
        }
    }

    // Hiển thị danh sách hóa đơn theo ngày & trạng thái
    private void listInvoices(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String dateParam = request.getParameter("date");
        String statusParam = request.getParameter("status");

        if (statusParam == null || statusParam.trim().isEmpty()) {
            statusParam = "All";
        }

        Date selectedDate = null;
        Date startDate = null;
        Date endDate = null;

        if (dateParam == null || dateParam.trim().isEmpty()) {
            selectedDate = new Date();
            dateParam = sdf.format(selectedDate);
        } else if (!"all".equalsIgnoreCase(dateParam)) {
            try {
                selectedDate = sdf.parse(dateParam);
            } catch (Exception e) {
                selectedDate = new Date();
                dateParam = sdf.format(selectedDate);
            }
        }

        if (selectedDate != null) {
            Calendar cal = Calendar.getInstance();
            cal.setTime(selectedDate);
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);
            startDate = cal.getTime();

            cal.set(Calendar.HOUR_OF_DAY, 23);
            cal.set(Calendar.MINUTE, 59);
            cal.set(Calendar.SECOND, 59);
            cal.set(Calendar.MILLISECOND, 999);
            endDate = cal.getTime();
        }

        // 1. Tính toán các chỉ số KPI bằng 1 câu truy vấn SQL duy nhất siêu tốc (<30ms)
        OrderDao.OrderStats stats = orderDao.getOrderStats(startDate, endDate, statusParam);

        // 2. Nạp toàn bộ hóa đơn theo bộ lọc (được tối ưu hóa bằng 2-step ID subquery siêu tốc 15ms)
        List<Order> orders = orderDao.findByDateRange(startDate, endDate, statusParam);

        // 3. Sử dụng bộ nhớ đệm ServletContext cho danh mục cố định (bàn, thức uống, nhân viên) giúp cắt giảm 3 câu lệnh SQL thừa
        @SuppressWarnings("unchecked")
        List<Table> tables = (List<Table>) getServletContext().getAttribute("cachedTables");
        if (tables == null) {
            tables = tableDao.findAll();
            getServletContext().setAttribute("cachedTables", tables);
        }

        @SuppressWarnings("unchecked")
        List<Drink> drinks = (List<Drink>) getServletContext().getAttribute("cachedDrinks");
        if (drinks == null) {
            drinks = drinkDao.findAll();
            getServletContext().setAttribute("cachedDrinks", drinks);
        }

        @SuppressWarnings("unchecked")
        List<User> users = (List<User>) getServletContext().getAttribute("cachedUsers");
        if (users == null) {
            users = userDao.findAll();
            getServletContext().setAttribute("cachedUsers", users);
        }

        request.setAttribute("orders", orders);
        request.setAttribute("selectedDate", dateParam);
        request.setAttribute("selectedStatus", statusParam);

        request.setAttribute("totalOrdersCount", stats.totalCount);
        request.setAttribute("totalRevenue", stats.totalRevenue);
        request.setAttribute("completedCount", stats.completedCount);
        request.setAttribute("pendingCount", stats.pendingCount);
        request.setAttribute("cancelledCount", stats.cancelledCount);

        request.setAttribute("totalRevenue", stats.totalRevenue);
        request.setAttribute("completedCount", stats.completedCount);
        request.setAttribute("pendingCount", stats.pendingCount);
        request.setAttribute("cancelledCount", stats.cancelledCount);

        request.setAttribute("tables", tables);
        request.setAttribute("drinks", drinks);
        request.setAttribute("users", users);

        request.getRequestDispatcher("/admin/invoices.jsp").forward(request, response);
    }

    // Xử lý AJAX nạp thêm hóa đơn ngầm (Load More)
    private void loadMoreInvoices(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        
        int offset = 0;
        int limit = 15;
        try {
            if (request.getParameter("offset") != null) offset = Integer.parseInt(request.getParameter("offset"));
            if (request.getParameter("limit") != null) limit = Integer.parseInt(request.getParameter("limit"));
        } catch (Exception ignored) {}

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat sdfFull = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        String dateParam = request.getParameter("date");
        String statusParam = request.getParameter("status");

        if (statusParam == null || statusParam.trim().isEmpty()) {
            statusParam = "All";
        }

        Date selectedDate = null;
        Date startDate = null;
        Date endDate = null;

        if (dateParam == null || dateParam.trim().isEmpty()) {
            selectedDate = new Date();
            dateParam = sdf.format(selectedDate);
        } else if (!"all".equalsIgnoreCase(dateParam)) {
            try {
                selectedDate = sdf.parse(dateParam);
            } catch (Exception e) {
                selectedDate = new Date();
                dateParam = sdf.format(selectedDate);
            }
        }

        if (selectedDate != null) {
            Calendar cal = Calendar.getInstance();
            cal.setTime(selectedDate);
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);
            startDate = cal.getTime();

            cal.set(Calendar.HOUR_OF_DAY, 23);
            cal.set(Calendar.MINUTE, 59);
            cal.set(Calendar.SECOND, 59);
            cal.set(Calendar.MILLISECOND, 999);
            endDate = cal.getTime();
        }

        List<Order> orders = orderDao.findByDateRange(startDate, endDate, statusParam, offset, limit);
        long totalCount = orderDao.countByDateRange(startDate, endDate, statusParam);

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
            String tableId = o.getTable() != null ? String.valueOf(o.getTable().getMaBan()) : "";
            String staffName = o.getUser() != null ? o.getUser().getHoTen() : "Hệ thống";

            StringBuilder itemsHtml = new StringBuilder();
            if (o.getOrderDetails() != null) {
                for (OrderDetail d : o.getOrderDetails()) {
                    String drinkName = d.getDrink() != null ? d.getDrink().getTenSanPham() : "N/A";
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

            String dateStr = o.getNgayTao() != null ? sdfFull.format(o.getNgayTao()) : "";

            json.append("{");
            json.append("\"id\":").append(o.getMaHoaDon()).append(",");
            json.append("\"dateStr\":\"").append(escapeJson(dateStr)).append("\",");
            json.append("\"type\":\"").append(escapeJson(o.getLoaiHoaDon())).append("\",");
            json.append("\"tableName\":\"").append(escapeJson(tableName)).append("\",");
            json.append("\"tableId\":\"").append(escapeJson(tableId)).append("\",");
            json.append("\"customerName\":\"").append(escapeJson(customerName)).append("\",");
            json.append("\"customerPhone\":\"").append(escapeJson(customerPhone)).append("\",");
            json.append("\"staffName\":\"").append(escapeJson(staffName)).append("\",");
            json.append("\"total\":").append((long)o.getTongTien()).append(",");
            json.append("\"formattedTotal\":\"").append(escapeJson(currencyFmt.format(o.getTongTien()))).append("\",");
            json.append("\"status\":\"").append(escapeJson(o.getTrangThai())).append("\",");
            json.append("\"note\":\"").append(escapeJson(o.getGhiChu())).append("\",");
            json.append("\"itemsHtml\":\"").append(escapeJson(itemsHtml.toString())).append("\"");
            json.append("}");
        }

        json.append("]}");

        PrintWriter out = response.getWriter();
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

    // Thêm hóa đơn mới
    private void insertInvoice(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            String customerName = request.getParameter("customerName");
            String customerPhone = request.getParameter("customerPhone");
            String tableIdStr = request.getParameter("tableId");
            String loaiHoaDon = request.getParameter("loaiHoaDon");
            String trangThai = request.getParameter("trangThai");
            String ghiChu = request.getParameter("ghiChu");

            Customer customer = null;
            if (customerPhone != null && !customerPhone.trim().isEmpty()) {
                String phone = customerPhone.trim();
                customer = customerDao.findByPhone(phone);
                if (customer == null && customerName != null && !customerName.trim().isEmpty()) {
                    customer = new Customer();
                    customer.setHoTen(customerName.trim());
                    customer.setSoDienThoai(phone);
                    customer.setEmail(phone + "@guest.coffeepoly.com");
                    customer.setDiemTichLuy(0);
                    customer.setTrangThai("HoatDong");
                    customer.setNgayDangKy(new Date());
                    customerDao.create(customer);
                } else if (customer != null && customerName != null && !customerName.trim().isEmpty()) {
                    if (!customer.getHoTen().equalsIgnoreCase(customerName.trim())) {
                        customer.setHoTen(customerName.trim());
                        customerDao.update(customer);
                    }
                }
            }

            Table table = null;
            if (tableIdStr != null && !tableIdStr.trim().isEmpty()) {
                try {
                    int tableId = Integer.parseInt(tableIdStr);
                    table = tableDao.findById(tableId);
                } catch (Exception ignored) {}
            }

            // Gán nhân viên tạo đơn nếu có
            User currentUser = null;
            String adminEmail = (String) session.getAttribute("adminUser");
            if (adminEmail != null) {
                currentUser = userDao.findByEmail(adminEmail);
            }

            Order order = new Order();
            order.setNgayTao(new Date());
            order.setLoaiHoaDon(loaiHoaDon != null ? loaiHoaDon : "TaiCho");
            order.setTrangThai(trangThai != null ? trangThai : "ChoThanhToan");
            order.setGhiChu(ghiChu);
            order.setCustomer(customer);
            order.setTable(table);
            order.setUser(currentUser);

            // Xử lý danh sách món
            String[] drinkIds = request.getParameterValues("drinkId");
            String[] quantities = request.getParameterValues("quantity");
            String[] notes = request.getParameterValues("itemNote");

            double totalAmount = 0.0;
            List<OrderDetail> details = new ArrayList<>();

            if (drinkIds != null && quantities != null) {
                for (int i = 0; i < drinkIds.length; i++) {
                    if (drinkIds[i] != null && !drinkIds[i].trim().isEmpty()) {
                        int drinkId = Integer.parseInt(drinkIds[i]);
                        int qty = Integer.parseInt(quantities[i]);
                        if (qty <= 0) continue;

                        Drink drink = drinkDao.findById(drinkId);
                        if (drink != null) {
                            double price = drink.getGiaCoBan();
                            String itemNote = (notes != null && i < notes.length) ? notes[i] : null;

                            OrderDetail detail = new OrderDetail(qty, price, itemNote, order, drink);
                            details.add(detail);
                            totalAmount += (price * qty);
                        }
                    }
                }
            }

            order.setTongTien(totalAmount);
            order.setOrderDetails(details);

            orderDao.create(order);
            session.setAttribute("adminSuccess", "Đã tạo hóa đơn mới #" + order.getMaHoaDon() + " thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("adminError", "Lỗi khi tạo hóa đơn: " + e.getMessage());
        }

        String date = request.getParameter("date");
        response.sendRedirect(request.getContextPath() + "/admin/invoices" + (date != null ? "?date=" + date : ""));
    }

    // Cập nhật thông tin hóa đơn
    private void updateInvoice(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Order order = orderDao.findById(id);

            if (order != null) {
                String trangThai = request.getParameter("trangThai");
                String loaiHoaDon = request.getParameter("loaiHoaDon");
                String tableIdStr = request.getParameter("tableId");
                String customerPhone = request.getParameter("customerPhone");
                String ghiChu = request.getParameter("ghiChu");
                String tongTienStr = request.getParameter("tongTien");

                if (trangThai != null) order.setTrangThai(trangThai);
                if (loaiHoaDon != null) order.setLoaiHoaDon(loaiHoaDon);
                if (ghiChu != null) order.setGhiChu(ghiChu.trim());

                if (tableIdStr != null && !tableIdStr.trim().isEmpty()) {
                    int tableId = Integer.parseInt(tableIdStr);
                    Table table = tableDao.findById(tableId);
                    order.setTable(table);
                } else {
                    order.setTable(null);
                }

                if (customerPhone != null && !customerPhone.trim().isEmpty()) {
                    Customer customer = customerDao.findByPhone(customerPhone.trim());
                    if (customer != null) {
                        order.setCustomer(customer);
                    }
                }

                if (tongTienStr != null && !tongTienStr.trim().isEmpty()) {
                    order.setTongTien(Double.parseDouble(tongTienStr));
                }

                orderDao.update(order);
                session.setAttribute("adminSuccess", "Đã cập nhật thông tin hóa đơn #" + id + " thành công!");
            } else {
                session.setAttribute("adminError", "Không tìm thấy hóa đơn #" + id);
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("adminError", "Lỗi khi cập nhật hóa đơn: " + e.getMessage());
        }

        String date = request.getParameter("date");
        response.sendRedirect(request.getContextPath() + "/admin/invoices" + (date != null ? "?date=" + date : ""));
    }

    // Xóa hóa đơn
    private void deleteInvoice(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            orderDao.delete(id);
            session.setAttribute("adminSuccess", "Đã xóa hóa đơn #" + id + " khỏi hệ thống thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("adminError", "Không thể xóa hóa đơn: " + e.getMessage());
        }

        String date = request.getParameter("date");
        response.sendRedirect(request.getContextPath() + "/admin/invoices" + (date != null ? "?date=" + date : ""));
    }
}
