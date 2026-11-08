package entity;

import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.io.Serializable;

/**
 * Entity đại diện cho bảng SanPham (Sản phẩm / Nước uống).
 */
@Entity
@Table(name = "SanPham") 
public class Drink implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaSanPham")
    private int maSanPham;

    @Column(name = "TenSanPham", nullable = false, length = 100)
    private String tenSanPham;

    @Column(name = "GiaCoBan", nullable = false)
    private double giaCoBan;

    @Column(name = "HinhAnh", columnDefinition = "TEXT")
    private String hinhAnh;

    @Column(name = "MoTa", columnDefinition = "TEXT")
    private String moTa;

    @Column(name = "TrangThai", length = 20)
    private String trangThai = "DangBan"; // DangBan, NgungBan

    // Quan hệ N-1: Nhiều sản phẩm thuộc về một danh mục
    @ManyToOne
    @JoinColumn(name = "MaDanhMuc")
    private Category category;

    public Drink() {
    }

    public Drink(String tenSanPham, double giaCoBan, String hinhAnh, String moTa, String trangThai, Category category) {
        this.tenSanPham = tenSanPham;
        this.giaCoBan = giaCoBan;
        this.hinhAnh = hinhAnh;
        this.moTa = moTa;
        this.trangThai = trangThai;
        this.category = category;
    }

    // Getters and Setters
    public int getMaSanPham() {
        return maSanPham;
    }

    public void setMaSanPham(int maSanPham) {
        this.maSanPham = maSanPham;
    }

    public String getTenSanPham() {
        return tenSanPham;
    }

    public void setTenSanPham(String tenSanPham) {
        this.tenSanPham = tenSanPham;
    }

    public double getGiaCoBan() {
        return giaCoBan;
    }

    public void setGiaCoBan(double giaCoBan) {
        this.giaCoBan = giaCoBan;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }
}
