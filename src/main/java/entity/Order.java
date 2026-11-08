package entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * Entity đại diện cho bảng HoaDon (Hóa đơn mua hàng).
 */
@Entity
@jakarta.persistence.Table(name = "HoaDon")
public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaHoaDon")
    private int maHoaDon;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "NgayTao")
    private Date ngayTao = new Date();

    @Column(name = "TongTien", nullable = false)
    private double tongTien;

    @Column(name = "TrangThai", length = 50)
    private String trangThai = "ChoThanhToan"; // ChoThanhToan, DangCheBien, DaGiao, DaThanhToan, DaHuy

    @Column(name = "LoaiHoaDon", length = 20)
    private String loaiHoaDon = "TaiCho"; // TaiCho, MangVe

    @Column(name = "GhiChu", length = 255)
    private String ghiChu;

    @ManyToOne
    @JoinColumn(name = "MaBan")
    private Table table;

    @ManyToOne
    @JoinColumn(name = "MaNguoiDung")
    private User user;

    @ManyToOne
    @JoinColumn(name = "MaKhachHang")
    private Customer customer;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @org.hibernate.annotations.BatchSize(size = 50)
    private List<OrderDetail> orderDetails;

    public Order() {
    }

    public Order(Date ngayTao, double tongTien, String trangThai, String loaiHoaDon, Table table, User user) {
        this.ngayTao = ngayTao;
        this.tongTien = tongTien;
        this.trangThai = trangThai;
        this.loaiHoaDon = loaiHoaDon;
        this.table = table;
        this.user = user;
    }

    // Getters and Setters
    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public int getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(int maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public Date getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(Date ngayTao) {
        this.ngayTao = ngayTao;
    }

    public double getTongTien() {
        return tongTien;
    }

    public void setTongTien(double tongTien) {
        this.tongTien = tongTien;
    }

    public String getTrangThai() {
        return trangThai != null ? trangThai.trim() : null;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getLoaiHoaDon() {
        return loaiHoaDon;
    }

    public void setLoaiHoaDon(String loaiHoaDon) {
        this.loaiHoaDon = loaiHoaDon;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public Table getTable() {
        return table;
    }

    public void setTable(Table table) {
        this.table = table;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<OrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<OrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }
}
