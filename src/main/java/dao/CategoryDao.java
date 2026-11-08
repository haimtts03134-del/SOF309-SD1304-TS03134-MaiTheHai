package dao;

import entity.Category;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.util.List;

/**
 * Lớp DAO thực hiện các truy vấn trên bảng DanhMuc.
 */
public class CategoryDao {

    /**
     * Lấy danh sách tất cả danh mục từ cơ sở dữ liệu.
     * 
     * @return List<Category>
     */
    public List<Category> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT c FROM Category c";
            TypedQuery<Category> query = em.createQuery(jpql, Category.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm danh mục theo mã định danh.
     * 
     * @param id Mã danh mục
     * @return Category
     */
    public Category findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(Category.class, id);
        } finally {
            em.close();
        }
    }
}
