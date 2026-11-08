package entity;

import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.io.Serializable;

/**
 * Entity đại diện cho bảng ChiTietHoaDon (Chi tiết từng món uống trong hóa đơn).
 */
@Entity
@Table(name = "ChiTietHoaDon") 
public class OrderDetail implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaChiTiet")
    private int maChiTiet;

    @Column(name = "SoLuong", nullable = false)
    private int soLuong;

    @Column(name = "DonGia", nullable = false)
    private double donGia;

    @Column(name = "GhiChu", length = 255)
    private String ghiChu;

    @ManyToOne
    @JoinColumn(name = "MaHoaDon")
    private Order order;

    @ManyToOne
    @JoinColumn(name = "MaSanPham")
    private Drink drink;

    public OrderDetail() {
    }

    public OrderDetail(int soLuong, double donGia, String ghiChu, Order order, Drink drink) {
        this.soLuong = soLuong;
        this.donGia = donGia;
        this.ghiChu = ghiChu;
        this.order = order;
        this.drink = drink;
    }

    // Getters and Setters
    public int getMaChiTiet() {
        return maChiTiet;
    }

    public void setMaChiTiet(int maChiTiet) {
        this.maChiTiet = maChiTiet;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public double getDonGia() {
        return donGia;
    }

    public void setDonGia(double donGia) {
        this.donGia = donGia;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }

    public Drink getDrink() {
        return drink;
    }

    public void setDrink(Drink drink) {
        this.drink = drink;
    }
}
