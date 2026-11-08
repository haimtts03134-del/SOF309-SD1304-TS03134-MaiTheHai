package controller.customer;

import dao.CustomerDao;
import dao.DrinkDao;
import dao.OrderDao;
import dao.TableDao;
import entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Servlet xử lý yêu cầu đặt món (đặt hàng) từ phía khách hàng (Không cần đăng nhập).
 */
@WebServlet("/place-order")
public class PlaceOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CustomerDao customerDao;
    private DrinkDao drinkDao;
    private OrderDao orderDao;

    @Override
    public void init() throws ServletException {
        customerDao = new CustomerDao();
        drinkDao = new DrinkDao();
        orderDao = new OrderDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();

        // 1. Nhận thông tin khách hàng và hình thức đặt món
        String customerName = request.getParameter("customerName");
        String customerPhone = request.getParameter("customerPhone");
        String note = request.getParameter("note");
        String orderType = request.getParameter("orderType"); // "TaiCho" hoặc "MangVe"
        String usePointsStr = request.getParameter("usePoints"); // Số điểm khách muốn sử dụng

        // 2. Nhận thông tin giỏ hàng
        String[] drinkIds = request.getParameterValues("drinkIds");
        String[] quantities = request.getParameterValues("quantities");

        // Kiểm tra hợp lệ dữ liệu cơ bản
        if (customerName == null || customerName.trim().isEmpty() ||
            customerPhone == null || customerPhone.trim().isEmpty() ||
            drinkIds == null || drinkIds.length == 0) {
            
            session.setAttribute("orderError", "Thông tin đặt món hoặc giỏ hàng không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/menu");
            return;
        }

        if (!customerPhone.trim().matches("^(03|05|07|08|09)\\d{8}$")) {
            session.setAttribute("orderError", "Số điện thoại không hợp lệ! Vui lòng nhập 10 chữ số bắt đầu bằng các đầu số 03, 05, 07, 08 hoặc 09 (Ví dụ: 0912345678, 0381234567).");
            response.sendRedirect(request.getContextPath() + "/menu");
            return;
        }

        try {
            // 3. Xử lý thông tin Khách hàng (bảo mật thông tin & kiểm tra tồn tại)
            customerName = customerName.trim();
            customerPhone = customerPhone.trim();
            
            // Tìm kiếm khách hàng theo số điện thoại
            Customer customer = customerDao.findByPhone(customerPhone);
            if (customer == null) {
                // Tạo mới nếu chưa tồn tại
                customer = new Customer();
                customer.setHoTen(customerName);
                customer.setSoDienThoai(customerPhone);
                // Tránh lỗi UNIQUE constraint của SQL Server khi có nhiều khách hàng vãng lai không điền email
                customer.setEmail(customerPhone + "@guest.coffeepoly.com");
                customer.setDiemTichLuy(0);
                customer.setTrangThai("HoatDong");
                customer.setNgayDangKy(new Date());
                customerDao.create(customer);
            } else {
                // Nếu khách hàng cũ đổi tên, cập nhật lại tên mới cho họ
                if (!customer.getHoTen().equalsIgnoreCase(customerName)) {
                    customer.setHoTen(customerName);
                    customerDao.update(customer);
                }
            }

            // 4. Xác định số điểm sử dụng & Giảm giá (Mới: Tối thiểu 50 điểm, 50 điểm = 7% giảm giá, tối đa 200 điểm/lần, mốc bội số 50)
            int rawPoints = 0;
            if (usePointsStr != null && !usePointsStr.trim().isEmpty()) {
                try {
                    rawPoints = Integer.parseInt(usePointsStr.trim());
                    if (rawPoints < 0) rawPoints = 0;
                } catch (Exception e) {
                    rawPoints = 0;
                }
            }

            int availablePoints = customer.getDiemTichLuy();
            int usedPoints = 0;

            // Yêu cầu tối thiểu từ 50 điểm tích lũy trở lên mới được đổi
            if (availablePoints >= 50 && rawPoints >= 50) {
                int maxCanUse = Math.min(rawPoints, availablePoints);
                maxCanUse = Math.min(200, maxCanUse); // Giới hạn tối đa 200 điểm/lần
                usedPoints = (maxCanUse / 50) * 50;   // Quy đổi theo từng mốc 50 điểm (50, 100, 150, 200)
            } else {
                usedPoints = 0;
            }

            // 5. Xác định Hình thức hóa đơn & Bàn phục vụ (TaiCho hoặc MangVe)
            String finalOrderType = ("MangVe".equalsIgnoreCase(orderType)) ? "MangVe" : "TaiCho";
            Table selectedTable = null;

            if ("TaiCho".equals(finalOrderType)) {
                String tableIdStr = request.getParameter("tableId");
                if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                    Object sessTableIdObj = session.getAttribute("sessionTableId");
                    if (sessTableIdObj != null) {
                        tableIdStr = String.valueOf(sessTableIdObj);
                    }
                }
                if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                    tableIdStr = request.getParameter("table");
                }
                if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
                    tableIdStr = request.getParameter("qr");
                }

                TableDao tableDao = new TableDao();
                if (tableIdStr != null && !tableIdStr.trim().isEmpty()) {
                    tableIdStr = tableIdStr.trim();
                    try {
                        int tableId = Integer.parseInt(tableIdStr);
                        selectedTable = tableDao.findById(tableId);
                    } catch (NumberFormatException ex) {
                        selectedTable = tableDao.findByQR(tableIdStr);
                        if (selectedTable == null) {
                            selectedTable = tableDao.findByTenBan(tableIdStr);
                        }
                    }
                }

                // Nếu vẫn chưa tìm được bàn khi chọn Phục vụ tại quán, báo lỗi để khách chọn bàn
                if (selectedTable == null) {
                    session.setAttribute("orderError", "Vui lòng chọn số bàn quý khách đang ngồi để nhân viên phục vụ tận nơi!");
                    response.sendRedirect(request.getContextPath() + "/menu");
                    return;
                }
            }

            // 6. Tạo Hóa đơn (Order)
            Order order = new Order();
            order.setNgayTao(new Date());
            order.setTrangThai("ChoThanhToan");
            order.setLoaiHoaDon(finalOrderType);
            order.setTable(selectedTable);
            order.setCustomer(customer);
            order.setUser(null); // Chưa có nhân viên xử lý

            // 7. Tạo chi tiết hóa đơn (OrderDetail) & Tính tổng tiền
            List<OrderDetail> details = new ArrayList<>();
            double totalAmount = 0;

            for (int i = 0; i < drinkIds.length; i++) {
                int drinkId = Integer.parseInt(drinkIds[i]);
                int qty = Integer.parseInt(quantities[i]);

                if (qty <= 0) continue;

                Drink drink = drinkDao.findById(drinkId);
                if (drink != null && "DangBan".equals(drink.getTrangThai())) {
                    OrderDetail detail = new OrderDetail();
                    detail.setDrink(drink);
                    detail.setSoLuong(qty);
                    detail.setDonGia(drink.getGiaCoBan());
                    detail.setGhiChu("");
                    detail.setOrder(order);
                    
                    details.add(detail);
                    totalAmount += drink.getGiaCoBan() * qty;
                }
            }

            if (details.isEmpty()) {
                session.setAttribute("orderError", "Giỏ hàng của bạn không có món nào đang bán!");
                response.sendRedirect(request.getContextPath() + "/menu");
                return;
            }

            // Tính giảm giá theo điểm tích lũy mới (50 điểm = 7% giảm giá)
            double discountPercent = (usedPoints / 50.0) * 7.0;
            double discountAmount = totalAmount * (discountPercent / 100.0);
            double finalTotal = totalAmount - discountAmount;
            if (finalTotal < 0) finalTotal = 0;

            String orderNote = (note != null) ? note.trim() : "";
            if (selectedTable != null) {
                session.setAttribute("sessionTableId", selectedTable.getMaBan());
                session.setAttribute("sessionTableName", selectedTable.getTenBan());

                jakarta.servlet.http.Cookie tableCookie = new jakarta.servlet.http.Cookie("coffee_table_id", String.valueOf(selectedTable.getMaBan()));
                tableCookie.setMaxAge(24 * 60 * 60);
                tableCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                response.addCookie(tableCookie);

                String tableNote = "[Vị trí: " + selectedTable.getTenBan() + "]";
                orderNote = orderNote.isEmpty() ? tableNote : tableNote + " " + orderNote;
            }
            if (usedPoints > 0) {
                String discountNote = "[Dùng " + usedPoints + " điểm giảm " + String.format("%.1f", discountPercent) + "% (-" + (int)discountAmount + "đ)]";
                orderNote = orderNote.isEmpty() ? discountNote : orderNote + " " + discountNote;
            }

            order.setGhiChu(orderNote);
            order.setOrderDetails(details);
            order.setTongTien(finalTotal);

            // 8. Lưu hóa đơn vào cơ sở dữ liệu
            orderDao.create(order);
            
            // Cập nhật điểm tích lũy: Trừ điểm sử dụng + Cộng điểm từ hóa đơn mới (10,000đ = 1 điểm)
            int remainingPoints = customer.getDiemTichLuy() - usedPoints;
            int newPoints = (int) (finalTotal / 10000);
            customer.setDiemTichLuy(remainingPoints + newPoints);
            customerDao.update(customer);

            // Đảm bảo không ghi nhớ thông tin khách hàng cũ nhằm bảo mật điểm tích lũy cho khách sau
            session.removeAttribute("sessionCustomerName");
            session.removeAttribute("sessionCustomerPhone");

            try {
                // Xóa Cookie thông tin khách hàng cũ trên máy khách nếu có
                jakarta.servlet.http.Cookie nameCookie = new jakarta.servlet.http.Cookie("coffee_cust_name", "");
                nameCookie.setMaxAge(0);
                nameCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                response.addCookie(nameCookie);

                jakarta.servlet.http.Cookie phoneCookie = new jakarta.servlet.http.Cookie("coffee_cust_phone", "");
                phoneCookie.setMaxAge(0);
                phoneCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                response.addCookie(phoneCookie);
            } catch (Exception ignored) {}

            // Xóa thông tin giỏ hàng ở Client (sẽ do JS xử lý sau khi chuyển sang thành công)
            // Chuyển hướng sang trang đặt món thành công (trong thư mục customer)
            response.sendRedirect(request.getContextPath() + "/customer/order-success.jsp?orderId=" + order.getMaHoaDon());

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("orderError", "Có lỗi xảy ra trong quá trình đặt món: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/menu");
        }
    }
}
