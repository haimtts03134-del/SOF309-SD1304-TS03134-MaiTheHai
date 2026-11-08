package entity;

import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.io.Serializable;

/**
 * Entity đại diện cho bảng VaiTro (Vai trò người dùng / phân quyền).
 */
@Entity
@Table(name = "VaiTro") 
public class Role implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "MaVaiTro", length = 20)
    private String maVaiTro;

    @Column(name = "TenVaiTro", nullable = false, length = 50)
    private String tenVaiTro;

    public Role() {
    }

    public Role(String maVaiTro, String tenVaiTro) {
        this.maVaiTro = maVaiTro;
        this.tenVaiTro = tenVaiTro;
    }

    public String getMaVaiTro() {
        return maVaiTro != null ? maVaiTro.trim() : null;
    }

    public void setMaVaiTro(String maVaiTro) {
        this.maVaiTro = maVaiTro;
    }

    public String getTenVaiTro() {
        return tenVaiTro;
    }

    public void setTenVaiTro(String tenVaiTro) {
        this.tenVaiTro = tenVaiTro;
    }
}
