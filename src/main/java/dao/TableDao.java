package dao;

import entity.Table;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.util.List;

/**
 * Lớp DAO thực hiện các truy vấn trên bảng Ban (Bàn ăn / Bàn nước).
 */
public class TableDao {

    /**
     * Lấy toàn bộ danh sách bàn.
     * 
     * @return List<Table>
     */
    public List<Table> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT t FROM Table t ORDER BY t.maBan ASC";
            TypedQuery<Table> query = em.createQuery(jpql, Table.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm bàn dựa trên mã Code QR.
     * 
     * @param qrCode Mã Code QR của bàn (Ví dụ: TABLE_01)
     * @return Table đối tượng bàn tìm thấy hoặc null nếu không tồn tại
     */
    public Table findByQR(String qrCode) {
        if (qrCode == null || qrCode.trim().isEmpty()) {
            return null;
        }
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT t FROM Table t WHERE t.maCodeQR = :qrCode";
            TypedQuery<Table> query = em.createQuery(jpql, Table.class);
            query.setParameter("qrCode", qrCode);
            List<Table> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm bàn theo mã bàn (ID).
     * 
     * @param id Mã bàn
     * @return Table
     */
    public Table findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(Table.class, id);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm bàn theo tên bàn (Ví dụ: Bàn 01).
     */
    public Table findByTenBan(String tenBan) {
        if (tenBan == null || tenBan.trim().isEmpty()) return null;
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT t FROM Table t WHERE LOWER(t.tenBan) = LOWER(:tenBan)";
            TypedQuery<Table> query = em.createQuery(jpql, Table.class);
            query.setParameter("tenBan", tenBan.trim());
            List<Table> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Thêm mới một bàn ăn.
     */
    public Table create(Table table) {
        EntityManager em = JpaUtils.getEntityManager();
        jakarta.persistence.EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(table);
            tx.commit();
            return table;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi thêm bàn mới: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật thông tin bàn ăn.
     */
    public Table update(Table table) {
        EntityManager em = JpaUtils.getEntityManager();
        jakarta.persistence.EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Table merged = em.merge(table);
            tx.commit();
            return merged;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật bàn: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Xóa bàn ăn theo ID.
     */
    public void delete(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        jakarta.persistence.EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Table table = em.find(Table.class, id);
            if (table != null) {
                em.remove(table);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi xóa bàn: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
}
