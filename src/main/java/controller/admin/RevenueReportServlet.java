package controller.admin;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.JpaUtils;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Servlet xử lý thống kê báo cáo doanh thu theo khoảng thời gian.
 */
@WebServlet("/admin/revenue")
public class RevenueReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        SimpleDateFormat paramFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat displayFormat = new SimpleDateFormat("dd/MM/yyyy");
        Calendar cal = Calendar.getInstance();

        Date startDate = null;
        Date endDate = null;

        String startStr = request.getParameter("startDate");
        String endStr = request.getParameter("endDate");

        try {
            // Xử lý Ngày bắt đầu
            if (startStr != null && !startStr.trim().isEmpty()) {
                startDate = paramFormat.parse(startStr);
            } else {
                // Mặc định là ngày đầu tiên của tháng hiện tại
                cal.set(Calendar.DAY_OF_MONTH, 1);
                cal.set(Calendar.HOUR_OF_DAY, 0);
                cal.set(Calendar.MINUTE, 0);
                cal.set(Calendar.SECOND, 0);
                cal.set(Calendar.MILLISECOND, 0);
                startDate = cal.getTime();
                startStr = paramFormat.format(startDate);
            }

            // Xử lý Ngày kết thúc
            if (endStr != null && !endStr.trim().isEmpty()) {
                endDate = paramFormat.parse(endStr);
                // Đặt thời gian đến 23:59:59.999 của ngày đó
                cal.setTime(endDate);
                cal.set(Calendar.HOUR_OF_DAY, 23);
                cal.set(Calendar.MINUTE, 59);
                cal.set(Calendar.SECOND, 59);
                cal.set(Calendar.MILLISECOND, 999);
                endDate = cal.getTime();
            } else {
                // Mặc định là cuối ngày hôm nay
                cal.setTime(new Date());
                cal.set(Calendar.HOUR_OF_DAY, 23);
                cal.set(Calendar.MINUTE, 59);
                cal.set(Calendar.SECOND, 59);
                cal.set(Calendar.MILLISECOND, 999);
                endDate = cal.getTime();
                endStr = paramFormat.format(endDate);
            }
        } catch (Exception e) {
            startDate = new Date();
            endDate = new Date();
        }

        EntityManager em = JpaUtils.getEntityManager();
        try {
            // 1. Thống kê KPI tổng quan: Doanh thu & Tổng số đơn hàng
            String jpqlKpis = "SELECT COALESCE(SUM(o.tongTien), 0.0), COUNT(o) FROM Order o " +
                              "WHERE o.trangThai = 'DaThanhToan' " +
                              "AND o.ngayTao >= :startDate AND o.ngayTao <= :endDate";
            Object[] kpis = em.createQuery(jpqlKpis, Object[].class)
                              .setParameter("startDate", startDate)
                              .setParameter("endDate", endDate)
                              .getSingleResult();

            double totalRevenue = (Double) kpis[0];
            long totalOrders = (Long) kpis[1];
            double aov = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("aov", aov);

            // 2. Thống kê Doanh thu & Số đơn theo Ngày (cho biểu đồ đường & bảng chi tiết)
            String jpqlDaily = "SELECT CAST(o.ngayTao AS date), SUM(o.tongTien), COUNT(o) FROM Order o " +
                               "WHERE o.trangThai = 'DaThanhToan' " +
                               "AND o.ngayTao >= :startDate AND o.ngayTao <= :endDate " +
                               "GROUP BY CAST(o.ngayTao AS date) " +
                               "ORDER BY CAST(o.ngayTao AS date) ASC";
            List<Object[]> dailyRaw = em.createQuery(jpqlDaily, Object[].class)
                                         .setParameter("startDate", startDate)
                                         .setParameter("endDate", endDate)
                                         .getResultList();

            List<String> chartLabels = new ArrayList<>();
            List<Double> chartData = new ArrayList<>();
            List<Map<String, Object>> dailyStats = new ArrayList<>();

            for (Object[] row : dailyRaw) {
                Date date = (Date) row[0];
                double revenue = (Double) row[1];
                long orders = (Long) row[2];

                String label = displayFormat.format(date);
                chartLabels.add(label);
                chartData.add(revenue);

                Map<String, Object> map = new HashMap<>();
                map.put("date", label);
                map.put("revenue", revenue);
                map.put("orders", orders);
                map.put("aov", orders > 0 ? revenue / orders : 0.0);
                dailyStats.add(map);
            }

            request.setAttribute("chartLabels", chartLabels);
            request.setAttribute("chartData", chartData);
            request.setAttribute("dailyStats", dailyStats);

            // 3. Thống kê số lượng nước bán chạy (cho biểu đồ doughnut)
            List<String> drinkLabels = new ArrayList<>();
            List<Long> drinkQuantities = new ArrayList<>();
            List<Double> drinkRevenues = new ArrayList<>();

            try {
                String jpqlDrinks = "SELECT COALESCE(d.tenSanPham, 'Khác'), SUM(od.soLuong), SUM(od.soLuong * od.donGia) " +
                                    "FROM OrderDetail od LEFT JOIN od.drink d " +
                                    "WHERE od.order.trangThai = 'DaThanhToan' " +
                                    "AND od.order.ngayTao >= :startDate AND od.order.ngayTao <= :endDate " +
                                    "GROUP BY COALESCE(d.tenSanPham, 'Khác') " +
                                    "ORDER BY SUM(od.soLuong) DESC";
                List<Object[]> drinkRaw = em.createQuery(jpqlDrinks, Object[].class)
                                          .setParameter("startDate", startDate)
                                          .setParameter("endDate", endDate)
                                          .getResultList();

                for (Object[] row : drinkRaw) {
                    drinkLabels.add((String) row[0]);
                    Number qty = (Number) row[1];
                    drinkQuantities.add(qty != null ? qty.longValue() : 0L);
                    Number rev = (Number) row[2];
                    drinkRevenues.add(rev != null ? rev.doubleValue() : 0.0);
                }
            } catch (Exception ex) {
                System.err.println("Lỗi khi truy vấn thống kê món nước: " + ex.getMessage());
                ex.printStackTrace();
            }

            request.setAttribute("drinkLabels", drinkLabels);
            request.setAttribute("drinkQuantities", drinkQuantities);
            request.setAttribute("drinkRevenues", drinkRevenues);
            // Giữ lại catLabels và catData để tương thích ngược với trang JSP cũ
            request.setAttribute("catLabels", drinkLabels);
            request.setAttribute("catData", drinkQuantities);

            // Gửi lại các tham số lọc để hiển thị lên form
            request.setAttribute("startDateStr", startStr);
            request.setAttribute("endDateStr", endStr);

        } finally {
            em.close();
        }

        request.getRequestDispatcher("/admin/revenue.jsp").forward(request, response);
    }
}
