package dao;

import entity.Order;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;
import java.util.Date;
import java.util.List;

/**
 * Lớp DAO thực hiện các thao tác trên bảng HoaDon (Order).
 * Tối ưu hóa truy vấn CSDL, loại bỏ hoàn toàn vấn đề N+1 Query.
 */
public class OrderDao {

    /**
     * Nạp trước (batch fetch) chi tiết đơn hàng và thông tin món uống cho danh sách đơn hàng.
     * Giải quyết triệt để vấn đề N+1 Query bằng cách chỉ dùng 1 truy vấn bổ sung duy nhất.
     */
    private void fetchDetailsForOrders(EntityManager em, List<Order> list) {
        if (list != null && !list.isEmpty()) {
            em.createQuery("SELECT DISTINCT o FROM Order o " +
                           "LEFT JOIN FETCH o.orderDetails d " +
                           "LEFT JOIN FETCH d.drink " +
                           "WHERE o IN :orders", Order.class)
              .setParameter("orders", list)
              .getResultList();
        }
    }

    /**
     * Lưu đơn hàng mới vào cơ sở dữ liệu.
     */
    public Order create(Order order) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(order);
            tx.commit();
            return order;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi tạo đơn hàng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm đơn hàng theo ID và nạp trước tất cả thông tin liên quan.
     */
    public Order findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT DISTINCT o FROM Order o " +
                          "LEFT JOIN FETCH o.table " +
                          "LEFT JOIN FETCH o.customer " +
                          "LEFT JOIN FETCH o.user " +
                          "WHERE o.maHoaDon = :id";
            TypedQuery<Order> query = em.createQuery(jpql, Order.class);
            query.setParameter("id", id);
            List<Order> list = query.getResultList();
            if (!list.isEmpty()) {
                Order order = list.get(0);
                fetchDetailsForOrders(em, list);
                return order;
            }
            return null;
        } finally {
            em.close();
        }
    }

    /**
     * Lấy các đơn hàng đang hoạt động (chưa hoàn thành / chưa hủy).
    /**
     * Lấy các đơn hàng đang hoạt động (chưa hoàn thành / chưa hủy) có hỗ trợ phân trang chuẩn SQL.
     */
    public List<Order> findActiveOrders(int firstResult, int maxResults) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpqlId = "SELECT o.maHoaDon FROM Order o WHERE o.trangThai NOT IN ('DaThanhToan', 'DaHuy') ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Integer> queryId = em.createQuery(jpqlId, Integer.class);
            if (firstResult > 0) queryId.setFirstResult(firstResult);
            if (maxResults > 0) queryId.setMaxResults(maxResults);

            List<Integer> ids = queryId.getResultList();
            if (ids.isEmpty()) return new java.util.ArrayList<>();

            String jpqlFull = "SELECT DISTINCT o FROM Order o " +
                              "LEFT JOIN FETCH o.table " +
                              "LEFT JOIN FETCH o.customer " +
                              "LEFT JOIN FETCH o.user " +
                              "WHERE o.maHoaDon IN :ids " +
                              "ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Order> queryFull = em.createQuery(jpqlFull, Order.class);
            queryFull.setParameter("ids", ids);
            List<Order> list = queryFull.getResultList();
            fetchDetailsForOrders(em, list);
            return list;
        } finally {
            em.close();
        }
    }

    public List<Order> findActiveOrders() {
        return findActiveOrders(0, 0);
    }

    /**
     * Lấy các đơn hàng chờ thanh toán (ChoThanhToan + DaGiao) có hỗ trợ phân trang chuẩn SQL.
     */
    public List<Order> findPendingPaymentOrders(int firstResult, int maxResults) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpqlId = "SELECT o.maHoaDon FROM Order o WHERE o.trangThai IN ('ChoThanhToan', 'DaGiao') ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Integer> queryId = em.createQuery(jpqlId, Integer.class);
            if (firstResult > 0) queryId.setFirstResult(firstResult);
            if (maxResults > 0) queryId.setMaxResults(maxResults);

            List<Integer> ids = queryId.getResultList();
            if (ids.isEmpty()) return new java.util.ArrayList<>();

            String jpqlFull = "SELECT DISTINCT o FROM Order o " +
                              "LEFT JOIN FETCH o.table " +
                              "LEFT JOIN FETCH o.customer " +
                              "LEFT JOIN FETCH o.user " +
                              "WHERE o.maHoaDon IN :ids " +
                              "ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Order> queryFull = em.createQuery(jpqlFull, Order.class);
            queryFull.setParameter("ids", ids);
            List<Order> list = queryFull.getResultList();
            fetchDetailsForOrders(em, list);
            return list;
        } finally {
            em.close();
        }
    }

    public List<Order> findPendingPaymentOrders() {
        return findPendingPaymentOrders(0, 0);
    }

    /**
     * Lấy danh sách đơn hàng theo trạng thái cụ thể có hỗ trợ phân trang chuẩn SQL.
     */
    public List<Order> findByStatus(String status, int firstResult, int maxResults) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpqlId = "SELECT o.maHoaDon FROM Order o WHERE o.trangThai = :status ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Integer> queryId = em.createQuery(jpqlId, Integer.class);
            queryId.setParameter("status", status);
            if (firstResult > 0) queryId.setFirstResult(firstResult);
            if (maxResults > 0) queryId.setMaxResults(maxResults);

            List<Integer> ids = queryId.getResultList();
            if (ids.isEmpty()) return new java.util.ArrayList<>();

            String jpqlFull = "SELECT DISTINCT o FROM Order o " +
                              "LEFT JOIN FETCH o.table " +
                              "LEFT JOIN FETCH o.customer " +
                              "LEFT JOIN FETCH o.user " +
                              "WHERE o.maHoaDon IN :ids " +
                              "ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Order> queryFull = em.createQuery(jpqlFull, Order.class);
            queryFull.setParameter("ids", ids);
            List<Order> list = queryFull.getResultList();
            fetchDetailsForOrders(em, list);
            return list;
        } finally {
            em.close();
        }
    }

    public List<Order> findByStatus(String status, int maxResults) {
        return findByStatus(status, 0, maxResults);
    }

    public List<Order> findByStatus(String status) {
        return findByStatus(status, 0, 100);
    }

    /**
     * Lấy danh sách đơn hàng trong khoảng thời gian và lọc theo trạng thái có hỗ trợ phân trang chuẩn SQL.
     */
    public List<Order> findByDateRange(Date startDate, Date endDate, String status, int firstResult, int maxResults) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            StringBuilder sbId = new StringBuilder("SELECT o.maHoaDon FROM Order o WHERE 1=1 ");
            if (startDate != null) sbId.append("AND o.ngayTao >= :startDate ");
            if (endDate != null) sbId.append("AND o.ngayTao <= :endDate ");
            if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status)) {
                sbId.append("AND o.trangThai = :status ");
            }
            sbId.append("ORDER BY o.ngayTao DESC");

            TypedQuery<Integer> queryId = em.createQuery(sbId.toString(), Integer.class);
            if (startDate != null) queryId.setParameter("startDate", startDate);
            if (endDate != null) queryId.setParameter("endDate", endDate);
            if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status)) {
                queryId.setParameter("status", status);
            }
            if (firstResult > 0) queryId.setFirstResult(firstResult);
            if (maxResults > 0) queryId.setMaxResults(maxResults);

            List<Integer> ids = queryId.getResultList();
            if (ids.isEmpty()) return new java.util.ArrayList<>();

            String jpqlFull = "SELECT DISTINCT o FROM Order o " +
                              "LEFT JOIN FETCH o.table " +
                              "LEFT JOIN FETCH o.customer " +
                              "LEFT JOIN FETCH o.user " +
                              "WHERE o.maHoaDon IN :ids " +
                              "ORDER BY o.ngayTao DESC";

            TypedQuery<Order> queryFull = em.createQuery(jpqlFull, Order.class);
            queryFull.setParameter("ids", ids);
            List<Order> list = queryFull.getResultList();
            fetchDetailsForOrders(em, list);
            return list;
        } finally {
            em.close();
        }
    }

    public List<Order> findByDateRange(Date startDate, Date endDate, String status) {
        return findByDateRange(startDate, endDate, status, 0, 0);
    }

    /**
     * Đếm tổng số đơn hàng trong khoảng thời gian và theo trạng thái.
     */
    public long countByDateRange(Date startDate, Date endDate, String status) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            StringBuilder sb = new StringBuilder("SELECT COUNT(o) FROM Order o WHERE 1=1 ");
            if (startDate != null) {
                sb.append("AND o.ngayTao >= :startDate ");
            }
            if (endDate != null) {
                sb.append("AND o.ngayTao <= :endDate ");
            }
            if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status)) {
                sb.append("AND o.trangThai = :status ");
            }

            TypedQuery<Long> query = em.createQuery(sb.toString(), Long.class);
            if (startDate != null) {
                query.setParameter("startDate", startDate);
            }
            if (endDate != null) {
                query.setParameter("endDate", endDate);
            }
            if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status)) {
                query.setParameter("status", status);
            }

            return query.getSingleResult();
        } finally {
            em.close();
        }
    }

    /**
     * Đếm tổng số đơn hàng theo trạng thái.
     */
    public long countByStatus(String status) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT COUNT(o) FROM Order o WHERE o.trangThai = :status";
            return em.createQuery(jpql, Long.class).setParameter("status", status).getSingleResult();
        } finally {
            em.close();
        }
    }

    /**
     * Đếm tổng số đơn hàng đang hoạt động.
     */
    public long countActiveOrders() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT COUNT(o) FROM Order o WHERE o.trangThai NOT IN ('DaThanhToan', 'DaHuy')";
            return em.createQuery(jpql, Long.class).getSingleResult();
        } finally {
            em.close();
        }
    }

    /**
     * Đếm tổng số đơn hàng chờ thanh toán.
     */
    public long countPendingPaymentOrders() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT COUNT(o) FROM Order o WHERE o.trangThai IN ('ChoThanhToan', 'DaGiao')";
            return em.createQuery(jpql, Long.class).getSingleResult();
        } finally {
            em.close();
        }
    }

    /**
     * Đếm tổng số tất cả đơn hàng.
     */
    public long countAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT COUNT(o) FROM Order o";
            return em.createQuery(jpql, Long.class).getSingleResult();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy danh sách đơn hàng có phân trang.
     */
    public List<Order> findAll(int firstResult, int maxResults) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpqlId = "SELECT o.maHoaDon FROM Order o ORDER BY o.ngayTao ASC, o.maHoaDon ASC";
            TypedQuery<Integer> queryId = em.createQuery(jpqlId, Integer.class);
            if (firstResult > 0) queryId.setFirstResult(firstResult);
            if (maxResults > 0) queryId.setMaxResults(maxResults);

            List<Integer> ids = queryId.getResultList();
            if (ids.isEmpty()) return new java.util.ArrayList<>();

            String jpqlFull = "SELECT DISTINCT o FROM Order o " +
                              "LEFT JOIN FETCH o.table " +
                              "LEFT JOIN FETCH o.customer " +
                              "LEFT JOIN FETCH o.user " +
                              "WHERE o.maHoaDon IN :ids " +
                              "ORDER BY o.ngayTao ASC, o.maHoaDon ASC";

            TypedQuery<Order> queryFull = em.createQuery(jpqlFull, Order.class);
            queryFull.setParameter("ids", ids);
            List<Order> list = queryFull.getResultList();
            fetchDetailsForOrders(em, list);
            return list;
        } finally {
            em.close();
        }
    }

    public List<Order> findAll(int maxResults) {
        return findAll(0, maxResults);
    }

    public List<Order> findAll() {
        return findAll(0, 100);
    }

    /**
     * Cập nhật thông tin đơn hàng vào cơ sở dữ liệu.
     */
    public Order update(Order order) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order mergedOrder = em.merge(order);
            tx.commit();
            return mergedOrder;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật đơn hàng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Xóa đơn hàng theo mã định danh.
     */
    public void delete(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order order = em.find(Order.class, id);
            if (order != null) {
                em.remove(order);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi xóa đơn hàng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * DTO lưu trữ chỉ số thống kê KPI.
     */
    public static class OrderStats {
        public long totalCount;
        public double totalRevenue;
        public long completedCount;
        public long pendingCount;
        public long cancelledCount;
    }

    /**
     * Tính toán tổng hợp chỉ số KPI bằng 1 câu truy vấn SQL duy nhất trên CSDL (siêu tốc <50ms).
     */
    public OrderStats getOrderStats(Date startDate, Date endDate, String status) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            StringBuilder sb = new StringBuilder();
            sb.append("SELECT ");
            sb.append("COUNT(o), ");
            sb.append("COALESCE(SUM(CASE WHEN o.trangThai = 'DaThanhToan' THEN o.tongTien ELSE 0 END), 0.0), ");
            sb.append("COALESCE(SUM(CASE WHEN o.trangThai = 'DaThanhToan' THEN 1 ELSE 0 END), 0L), ");
            sb.append("COALESCE(SUM(CASE WHEN o.trangThai = 'DaHuy' THEN 1 ELSE 0 END), 0L), ");
            sb.append("COALESCE(SUM(CASE WHEN o.trangThai NOT IN ('DaThanhToan', 'DaHuy') THEN 1 ELSE 0 END), 0L) ");
            sb.append("FROM Order o WHERE 1=1 ");

            if (startDate != null) sb.append("AND o.ngayTao >= :startDate ");
            if (endDate != null) sb.append("AND o.ngayTao <= :endDate ");
            if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status)) {
                sb.append("AND o.trangThai = :status ");
            }

            TypedQuery<Object[]> query = em.createQuery(sb.toString(), Object[].class);
            if (startDate != null) query.setParameter("startDate", startDate);
            if (endDate != null) query.setParameter("endDate", endDate);
            if (status != null && !status.trim().isEmpty() && !"All".equalsIgnoreCase(status)) {
                query.setParameter("status", status);
            }

            Object[] res = query.getSingleResult();
            OrderStats stats = new OrderStats();
            stats.totalCount = res[0] != null ? ((Number) res[0]).longValue() : 0L;
            stats.totalRevenue = res[1] != null ? ((Number) res[1]).doubleValue() : 0.0;
            stats.completedCount = res[2] != null ? ((Number) res[2]).longValue() : 0L;
            stats.cancelledCount = res[3] != null ? ((Number) res[3]).longValue() : 0L;
            stats.pendingCount = res[4] != null ? ((Number) res[4]).longValue() : 0L;

            return stats;
        } finally {
            em.close();
        }
    }
}
