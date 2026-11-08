package controller.admin;

import entity.Order;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.JpaUtils;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet xử lý hiển thị Bảng điều khiển Admin (Dashboard) chứa dữ liệu thống kê thật từ cơ sở dữ liệu.
 * Tối ưu hóa truy vấn theo chỉ mục (SARGable) và tự động reset theo từng tháng.
 */
@WebServlet("/admin/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EntityManager em = JpaUtils.getEntityManager();
        try {
            // 1. Xác định tháng/năm cần thống kê (mặc định là tháng hiện tại)
            String monthParam = request.getParameter("month"); // Định dạng: YYYY-MM
            java.util.Calendar cal = java.util.Calendar.getInstance();

            if (monthParam != null && monthParam.matches("\\d{4}-\\d{2}")) {
                try {
                    String[] parts = monthParam.split("-");
                    int year = Integer.parseInt(parts[0]);
                    int month = Integer.parseInt(parts[1]) - 1; // Calendar month 0-indexed
                    cal.set(year, month, 1, 0, 0, 0);
                    cal.set(java.util.Calendar.MILLISECOND, 0);
                } catch (Exception e) {
                    cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
                    cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
                    cal.set(java.util.Calendar.MINUTE, 0);
                    cal.set(java.util.Calendar.SECOND, 0);
                    cal.set(java.util.Calendar.MILLISECOND, 0);
                }
            } else {
                cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
                cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
                cal.set(java.util.Calendar.MINUTE, 0);
                cal.set(java.util.Calendar.SECOND, 0);
                cal.set(java.util.Calendar.MILLISECOND, 0);
            }

            java.util.Date startDate = cal.getTime();
            cal.add(java.util.Calendar.MONTH, 1);
            java.util.Date endDate = cal.getTime();

            SimpleDateFormat ymFmt = new SimpleDateFormat("yyyy-MM");
            SimpleDateFormat displayMonthFmt = new SimpleDateFormat("MM/yyyy");
            String selectedMonth = ymFmt.format(startDate);
            String displayMonth = displayMonthFmt.format(startDate);

            request.setAttribute("selectedMonth", selectedMonth);
            request.setAttribute("displayMonth", displayMonth);

            // 2. Tối ưu gộp câu truy vấn KPI: Doanh thu & Tổng đơn hàng đã giao trong tháng (1 câu SQL duy nhất)
            String jpqlKpis = "SELECT COALESCE(SUM(o.tongTien), 0.0), COUNT(o) FROM Order o " +
                              "WHERE o.trangThai = 'DaThanhToan' " +
                              "AND o.ngayTao >= :startDate AND o.ngayTao < :endDate";
            Object[] kpiResult = em.createQuery(jpqlKpis, Object[].class)
                                  .setParameter("startDate", startDate)
                                  .setParameter("endDate", endDate)
                                  .getSingleResult();

            Double totalRevenue = (Double) kpiResult[0];
            Long ordersCount = (Long) kpiResult[1];

            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("ordersCount", ordersCount);

            // 3. Số lượng món trong thực đơn
            String jpqlDrinksCount = "SELECT COUNT(d) FROM Drink d";
            Long drinksCount = em.createQuery(jpqlDrinksCount, Long.class).getSingleResult();
            request.setAttribute("drinksCount", drinksCount);

            // 4. Các loại nước bán chạy nhất trong tháng (Top 5)
            String jpqlBestSellers = "SELECT od.drink.tenSanPham, od.drink.category.tenDanhMuc, " +
                                     "SUM(od.soLuong), SUM(od.soLuong * od.donGia) " +
                                     "FROM OrderDetail od " +
                                     "WHERE od.order.trangThai = 'DaThanhToan' " +
                                     "AND od.order.ngayTao >= :startDate AND od.order.ngayTao < :endDate " +
                                     "GROUP BY od.drink.tenSanPham, od.drink.category.tenDanhMuc " +
                                     "ORDER BY SUM(od.soLuong) DESC";
            List<Object[]> bestSellersRaw = em.createQuery(jpqlBestSellers, Object[].class)
                                              .setParameter("startDate", startDate)
                                              .setParameter("endDate", endDate)
                                              .setMaxResults(5)
                                              .getResultList();
            
            List<Map<String, Object>> bestSellers = new ArrayList<>();
            for (Object[] row : bestSellersRaw) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", row[0]);
                map.put("category", row[1]);
                map.put("soldCount", row[2]);
                map.put("totalSales", row[3]);
                bestSellers.add(map);
            }
            request.setAttribute("bestSellers", bestSellers);

            // 5. Nhân viên xuất sắc của tháng (Top 5)
            String jpqlTopEmployees = "SELECT o.user.hoTen, o.user.role.tenVaiTro, " +
                                      "COUNT(o), SUM(o.tongTien), o.user.hinhAnh " +
                                      "FROM Order o " +
                                      "WHERE o.trangThai = 'DaThanhToan' " +
                                      "AND o.user IS NOT NULL " +
                                      "AND o.ngayTao >= :startDate AND o.ngayTao < :endDate " +
                                      "GROUP BY o.user.hoTen, o.user.role.tenVaiTro, o.user.hinhAnh " +
                                      "ORDER BY SUM(o.tongTien) DESC";
            List<Object[]> topEmployeesRaw = em.createQuery(jpqlTopEmployees, Object[].class)
                                               .setParameter("startDate", startDate)
                                               .setParameter("endDate", endDate)
                                               .setMaxResults(5)
                                               .getResultList();
            
            List<Map<String, Object>> topEmployees = new ArrayList<>();
            for (Object[] row : topEmployeesRaw) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", row[0]);
                map.put("role", row[1]);
                map.put("orders", row[2]);
                map.put("sales", row[3]);
                
                String empAvatar = (String) row[4];
                if (empAvatar == null || empAvatar.trim().isEmpty()) {
                    empAvatar = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100";
                } else if (!empAvatar.startsWith("http")) {
                    empAvatar = request.getContextPath() + "/admin/images/" + empAvatar;
                }
                map.put("avatar", empAvatar);
                topEmployees.add(map);
            }
            request.setAttribute("topEmployees", topEmployees);

            // 6. Giao dịch gần đây trong tháng (5 đơn mới nhất)
            String jpqlRecent = "SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.table LEFT JOIN FETCH o.user " +
                                "WHERE o.ngayTao >= :startDate AND o.ngayTao < :endDate " +
                                "ORDER BY o.ngayTao DESC";
            List<Order> recentOrders = em.createQuery(jpqlRecent, Order.class)
                                         .setParameter("startDate", startDate)
                                         .setParameter("endDate", endDate)
                                         .setMaxResults(5)
                                         .getResultList();
            
            List<Map<String, Object>> recentTransactions = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm - dd/MM/yyyy");
            for (Order o : recentOrders) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", "HD" + o.getMaHoaDon());
                map.put("time", sdf.format(o.getNgayTao()));
                map.put("amount", o.getTongTien());
                map.put("method", "TaiCho".equalsIgnoreCase(o.getLoaiHoaDon()) ? "Tại quán" : "Mang về");
                
                String statusStr = "Chờ thanh toán";
                if ("DaThanhToan".equals(o.getTrangThai())) {
                    statusStr = "Đã thanh toán";
                } else if ("DaHuy".equals(o.getTrangThai())) {
                    statusStr = "Đã hủy";
                } else if ("DangCheBien".equals(o.getTrangThai())) {
                    statusStr = "Đang chế biến";
                } else if ("DaGiao".equals(o.getTrangThai())) {
                    statusStr = "Đã giao món";
                }
                map.put("status", statusStr);
                recentTransactions.add(map);
            }
            request.setAttribute("recentTransactions", recentTransactions);

            // 7. Tất cả hóa đơn trong tháng (Dành cho Pop-up Modal)
            List<Order> monthOrdersList = em.createQuery(jpqlRecent, Order.class)
                                            .setParameter("startDate", startDate)
                                            .setParameter("endDate", endDate)
                                            .getResultList();

            List<Map<String, Object>> monthOrders = new ArrayList<>();
            for (Order o : monthOrdersList) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", "HD" + o.getMaHoaDon());
                map.put("time", sdf.format(o.getNgayTao()));
                map.put("amount", o.getTongTien());
                
                boolean isTaiCho = false;
                String methodDisplay = "Mang về";
                if (o.getTable() != null && o.getTable().getTenBan() != null && !o.getTable().getTenBan().trim().isEmpty()) {
                    isTaiCho = true;
                    methodDisplay = o.getTable().getTenBan();
                } else if (o.getLoaiHoaDon() != null && ("TaiCho".equalsIgnoreCase(o.getLoaiHoaDon()) || "Tại bàn".equalsIgnoreCase(o.getLoaiHoaDon()) || "Tại quán".equalsIgnoreCase(o.getLoaiHoaDon()))) {
                    isTaiCho = true;
                    methodDisplay = "Tại quán";
                }

                map.put("method", methodDisplay);
                map.put("isTaiCho", Boolean.valueOf(isTaiCho));
                map.put("tableName", o.getTable() != null ? o.getTable().getTenBan() : "");
                map.put("staffName", o.getUser() != null ? o.getUser().getHoTen() : "Hệ thống / KH QR");
                
                String statusStr = "Chờ thanh toán";
                if ("DaThanhToan".equals(o.getTrangThai())) {
                    statusStr = "Đã thanh toán";
                } else if ("DaHuy".equals(o.getTrangThai())) {
                    statusStr = "Đã hủy";
                } else if ("DangCheBien".equals(o.getTrangThai())) {
                    statusStr = "Đang chế biến";
                } else if ("DaGiao".equals(o.getTrangThai())) {
                    statusStr = "Đã giao món";
                }
                map.put("status", statusStr);
                monthOrders.add(map);
            }
            request.setAttribute("monthOrders", monthOrders);

        } finally {
            em.close();
        }

        // Chuyển hướng sang trang JSP hiển thị
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
