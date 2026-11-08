package entity;

import jakarta.persistence.*;
import java.io.Serializable;

/**
 * Entity đại diện cho bảng Ban (Bàn của quán nước).
 */
@Entity
@jakarta.persistence.Table(name = "Ban")
public class Table implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaBan")
    private int maBan;

    @Column(name = "TenBan", nullable = false, length = 50)
    private String tenBan;

    @Column(name = "MaCodeQR", unique = true, length = 255)
    private String maCodeQR;

    @Column(name = "TrangThai", length = 20)
    private String trangThai = "Trong"; // Trong, CoKhach, DatTruoc, BaoTri

    public Table() {
    }

    public Table(String tenBan, String maCodeQR, String trangThai) {
        this.tenBan = tenBan;
        this.maCodeQR = maCodeQR;
        this.trangThai = trangThai;
    }

    // Getters and Setters
    public int getMaBan() {
        return maBan;
    }

    public void setMaBan(int maBan) {
        this.maBan = maBan;
    }

    public String getTenBan() {
        return tenBan;
    }

    public void setTenBan(String tenBan) {
        this.tenBan = tenBan;
    }

    public String getMaCodeQR() {
        return maCodeQR;
    }

    public void setMaCodeQR(String maCodeQR) {
        this.maCodeQR = maCodeQR;
    }

    public String getTrangThai() {
        return trangThai != null ? trangThai.trim() : null;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }
}
