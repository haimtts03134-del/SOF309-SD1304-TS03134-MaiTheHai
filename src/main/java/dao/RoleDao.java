package dao;

import entity.Role;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.util.List;

/**
 * Lớp DAO thực hiện các truy vấn trên bảng VaiTro.
 */
public class RoleDao {

    /**
     * Lấy danh sách tất cả vai trò từ cơ sở dữ liệu.
     * 
     * @return List<Role>
     */
    public List<Role> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT r FROM Role r";
            TypedQuery<Role> query = em.createQuery(jpql, Role.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm vai trò theo mã định danh.
     * 
     * @param id Mã vai trò (ví dụ: 'ADMIN', 'NHANVIEN')
     * @return Role
     */
    public Role findById(String id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(Role.class, id);
        } finally {
            em.close();
        }
    }
}
