package utils;

import jakarta.persistence.EntityManager;

public class AlterTableHinhAnh {
    public static void main(String[] args) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.createNativeQuery("ALTER TABLE SanPham ALTER COLUMN HinhAnh TYPE TEXT;").executeUpdate();
            em.getTransaction().commit();
            System.out.println("SUCCESS: Executed ALTER TABLE SanPham ALTER COLUMN HinhAnh TYPE TEXT;");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
