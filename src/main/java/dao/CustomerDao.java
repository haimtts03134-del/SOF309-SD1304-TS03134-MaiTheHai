package dao;

import entity.Customer;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.util.List;

/**
 * Lớp DAO thực hiện các thao tác CRUD trên bảng KhachHang (Khách hàng).
 */
public class CustomerDao {

    /**
     * Lấy toàn bộ danh sách khách hàng.
     * 
     * @return List<Customer>
     */
    public List<Customer> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c ORDER BY c.maKhachHang DESC";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm khách hàng theo mã định danh.
     * 
     * @param id Mã khách hàng
     * @return Customer
     */
    public Customer findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(Customer.class, id);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm khách hàng theo Số điện thoại.
     * 
     * @param phone Số điện thoại
     * @return Customer hoặc null nếu không tìm thấy
     */
    public Customer findByPhone(String phone) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c WHERE c.soDienThoai = :phone";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            query.setParameter("phone", phone);
            List<Customer> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm danh sách tối đa 5 khách hàng theo Tên hoặc Số điện thoại (Hỗ trợ tự động nhận diện / Gợi ý).
     */
    public List<Customer> searchByNameOrPhone(String keyword) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c WHERE LOWER(c.hoTen) LIKE LOWER(:kw) OR c.soDienThoai LIKE :kw ORDER BY c.maKhachHang DESC";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            query.setParameter("kw", "%" + keyword.trim() + "%");
            query.setMaxResults(5);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm khách hàng theo Email.
     * 
     * @param email Email khách hàng
     * @return Customer hoặc null nếu không tìm thấy
     */
    public Customer findByEmail(String email) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c WHERE c.email = :email";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            query.setParameter("email", email);
            List<Customer> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Thêm mới một khách hàng.
     * 
     * @param customer Đối tượng khách hàng cần thêm
     * @return Customer đối tượng sau khi lưu
     */
    public Customer create(Customer customer) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(customer);
            tx.commit();
            return customer;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi thêm khách hàng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật thông tin khách hàng.
     * 
     * @param customer Đối tượng khách hàng chứa thông tin mới
     * @return Customer đối tượng sau khi cập nhật
     */
    public Customer update(Customer customer) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Customer updated = em.merge(customer);
            tx.commit();
            return updated;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật khách hàng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Xóa khách hàng theo mã định danh.
     * 
     * @param id Mã khách hàng cần xóa
     */
    public void delete(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Customer customer = em.find(Customer.class, id);
            if (customer != null) {
                em.remove(customer);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi xóa khách hàng: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
}
