package dao;

import entity.Drink;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.util.List;

/**
 * Lớp DAO thực hiện các thao tác CRUD trên bảng SanPham (Đồ uống).
 */
public class DrinkDao {

    /**
     * Lấy toàn bộ danh sách đồ uống.
     * 
     * @return List<Drink>
     */
    public List<Drink> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT d FROM Drink d LEFT JOIN FETCH d.category";
            TypedQuery<Drink> query = em.createQuery(jpql, Drink.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy danh sách đồ uống đang kinh doanh (TrangThai = 'DangBan').
     * 
     * @return List<Drink>
     */
    public List<Drink> findActive() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT d FROM Drink d LEFT JOIN FETCH d.category WHERE d.trangThai = 'DangBan'";
            TypedQuery<Drink> query = em.createQuery(jpql, Drink.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm đồ uống theo mã định danh.
     * 
     * @param id Mã đồ uống
     * @return Drink
     */
    public Drink findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(Drink.class, id);
        } finally {
            em.close();
        }
    }

    /**
     * Thêm mới một đồ uống vào cơ sở dữ liệu.
     * 
     * @param drink Đối tượng đồ uống cần thêm
     * @return Drink đối tượng sau khi lưu (có kèm ID tự sinh)
     */
    public Drink create(Drink drink) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(drink);
            tx.commit();
            return drink;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi thêm đồ uống: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật thông tin đồ uống.
     * 
     * @param drink Đối tượng đồ uống chứa thông tin mới
     * @return Drink đối tượng sau khi cập nhật
     */
    public Drink update(Drink drink) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Drink updated = em.merge(drink);
            tx.commit();
            return updated;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật đồ uống: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Xóa đồ uống theo mã định danh.
     * 
     * @param id Mã đồ uống cần xóa
     */
    public void delete(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Drink drink = em.find(Drink.class, id);
            if (drink != null) {
                em.remove(drink);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi xóa đồ uống: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
}
