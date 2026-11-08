package controller.api;

import entity.Order;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.JpaUtils;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * REST API Servlet phục vụ tự động kiểm tra và thông báo đơn hàng mới (Real-time polling).
 * Cho phép cả trang Admin và Nhân viên nhận thông báo và cập nhật dữ liệu tự động mà không cần bấm F5.
 */
@WebServlet("/api/orders/poll")
public class OrderPollServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        
        String lastOrderIdStr = request.getParameter("lastOrderId");
        int lastOrderId = 0;
        if (lastOrderIdStr != null && !lastOrderIdStr.trim().isEmpty()) {
            try {
                lastOrderId = Integer.parseInt(lastOrderIdStr.trim());
            } catch (Exception e) {
                lastOrderId = 0;
            }
        }

        EntityManager em = JpaUtils.getEntityManager();
        try {
            // 1. Tìm mã đơn hàng lớn nhất hiện tại
            String jpqlMax = "SELECT COALESCE(MAX(o.maHoaDon), 0) FROM Order o";
            Integer maxOrderId = em.createQuery(jpqlMax, Integer.class).getSingleResult();

            // 2. Đếm số lượng đơn hàng theo từng trạng thái cụ thể
            Long choThanhToan = em.createQuery("SELECT COUNT(o) FROM Order o WHERE o.trangThai = 'ChoThanhToan'", Long.class).getSingleResult();
            Long dangCheBien = em.createQuery("SELECT COUNT(o) FROM Order o WHERE o.trangThai = 'DangCheBien'", Long.class).getSingleResult();
            Long daGiao = em.createQuery("SELECT COUNT(o) FROM Order o WHERE o.trangThai = 'DaGiao'", Long.class).getSingleResult();
            Long daThanhToan = em.createQuery("SELECT COUNT(o) FROM Order o WHERE o.trangThai = 'DaThanhToan'", Long.class).getSingleResult();
            Long daHuy = em.createQuery("SELECT COUNT(o) FROM Order o WHERE o.trangThai = 'DaHuy'", Long.class).getSingleResult();

            Long activeCount = choThanhToan + dangCheBien + daGiao;
            Long pendingCount = choThanhToan;

            // 3. Tạo chuỗi hash trạng thái duy nhất
            String statusHash = maxOrderId + "_" + choThanhToan + "_" + dangCheBien + "_" + daGiao + "_" + daThanhToan + "_" + daHuy;

            boolean hasNew = (maxOrderId > lastOrderId) && (lastOrderId > 0);

            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"maxOrderId\":").append(maxOrderId).append(",");
            json.append("\"activeCount\":").append(activeCount).append(",");
            json.append("\"pendingCount\":").append(pendingCount).append(",");
            json.append("\"statusHash\":\"").append(statusHash).append("\",");
            json.append("\"hasNew\":").append(hasNew);

            if (hasNew) {
                String jpqlNewOrders = "SELECT o FROM Order o LEFT JOIN FETCH o.customer WHERE o.maHoaDon > :lastId ORDER BY o.maHoaDon DESC";
                List<Order> newOrders = em.createQuery(jpqlNewOrders, Order.class)
                                          .setParameter("lastId", lastOrderId)
                                          .getResultList();

                SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
                json.append(",\"newOrders\":[");
                for (int i = 0; i < newOrders.size(); i++) {
                    Order o = newOrders.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"id\":").append(o.getMaHoaDon()).append(",");
                    json.append("\"customer\":\"").append(escapeJson(o.getCustomer() != null ? o.getCustomer().getHoTen() : "Khách vãng lai")).append("\",");
                    json.append("\"total\":").append((long)o.getTongTien()).append(",");
                    json.append("\"type\":\"").append("TaiCho".equals(o.getLoaiHoaDon()) ? "Tại quán" : "Mang về").append("\",");
                    json.append("\"time\":\"").append(sdf.format(o.getNgayTao())).append("\"");
                    json.append("}");
                }
                json.append("]");
            }

            json.append("}");

            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();

        } finally {
            em.close();
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", " ")
                    .replace("\r", " ");
    }
}
