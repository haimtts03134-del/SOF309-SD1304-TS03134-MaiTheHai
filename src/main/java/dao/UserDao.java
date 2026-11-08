package dao;

import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.util.List;

/**
 * Lớp DAO thực hiện các thao tác CRUD trên bảng NguoiDung (Người dùng / Tài khoản nhân viên).
 */
public class UserDao {

    /**
     * Lấy danh sách toàn bộ người dùng.
     * 
     * @return List<User>
     */
    public List<User> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u LEFT JOIN FETCH u.role";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm người dùng theo mã định danh.
     * 
     * @param id Mã người dùng
     * @return User
     */
    public User findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(User.class, id);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm người dùng theo Email.
     * 
     * @param email Email đăng nhập
     * @return User hoặc null nếu không tìm thấy
     */
    public User findByEmail(String email) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u LEFT JOIN FETCH u.role WHERE u.email = :email";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            query.setParameter("email", email);
            List<User> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Thêm mới một người dùng vào cơ sở dữ liệu.
     * 
     * @param user Đối tượng người dùng cần thêm
     * @return User đối tượng sau khi lưu
     */
    public User create(User user) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(user);
            tx.commit();
            return user;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi thêm người dùng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật thông tin người dùng.
     * 
     * @param user Đối tượng người dùng chứa thông tin mới
     * @return User đối tượng sau khi cập nhật
     */
    public User update(User user) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User updated = em.merge(user);
            tx.commit();
            return updated;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật người dùng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Xóa người dùng theo mã định danh.
     * 
     * @param id Mã người dùng cần xóa
     */
    public void delete(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, id);
            if (user != null) {
                em.remove(user);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi xóa người dùng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
}
