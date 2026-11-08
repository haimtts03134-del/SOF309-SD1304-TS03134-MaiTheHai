package entity;

import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.io.Serializable;
import java.util.List;

/**
 * Entity đại diện cho bảng DanhMuc (Danh mục đồ uống).
 */
@Entity
@Table(name = "DanhMuc") 
public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaDanhMuc")
    private int maDanhMuc;

    @Column(name = "TenDanhMuc", nullable = false, length = 100)
    private String tenDanhMuc;

    @Column(name = "MoTa", length = 255)
    private String moTa;

    // Quan hệ 1-N: Một danh mục có nhiều sản phẩm
    @OneToMany(mappedBy = "category", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Drink> drinks;

    public Category() {
    }

    public Category(int maDanhMuc) {
        this.maDanhMuc = maDanhMuc;
    }

    public Category(String tenDanhMuc, String moTa) {
        this.tenDanhMuc = tenDanhMuc;
        this.moTa = moTa;
    }

    // Getters and Setters
    public int getMaDanhMuc() {
        return maDanhMuc;
    }

    public void setMaDanhMuc(int maDanhMuc) {
        this.maDanhMuc = maDanhMuc;
    }

    public String getTenDanhMuc() {
        return tenDanhMuc;
    }

    public void setTenDanhMuc(String tenDanhMuc) {
        this.tenDanhMuc = tenDanhMuc;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public List<Drink> getDrinks() {
        return drinks;
    }

    public void setDrinks(List<Drink> drinks) {
        this.drinks = drinks;
    }
}
