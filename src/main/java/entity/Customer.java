package entity;

import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity đại diện cho bảng KhachHang (Khách hàng).
 */
@Entity
@Table(name = "KhachHang")
public class Customer implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaKhachHang")
    private int maKhachHang;

    @Column(name = "HoTen", nullable = false, length = 100)
    private String hoTen;

    @Column(name = "SoDienThoai", unique = true, nullable = false, length = 15)
    private String soDienThoai;

    @Column(name = "Email", unique = true, length = 100)
    private String email;

    @Column(name = "DiemTichLuy")
    private int diemTichLuy = 0;

    @Column(name = "TrangThai", length = 20)
    private String trangThai = "HoatDong"; // HoatDong, NgungHoatDong

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "NgayDangKy")
    private Date ngayDangKy = new Date();

    public Customer() {
    }

    public Customer(String hoTen, String soDienThoai, String email, int diemTichLuy, String trangThai) {
        this.hoTen = hoTen;
        this.soDienThoai = soDienThoai;
        this.email = email;
        this.diemTichLuy = diemTichLuy;
        this.trangThai = trangThai;
    }

    // Getters and Setters
    public int getMaKhachHang() {
        return maKhachHang;
    }

    public void setMaKhachHang(int maKhachHang) {
        this.maKhachHang = maKhachHang;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getDiemTichLuy() {
        return diemTichLuy;
    }

    public void setDiemTichLuy(int diemTichLuy) {
        this.diemTichLuy = diemTichLuy;
    }

    public String getTrangThai() {
        return trangThai != null ? trangThai.trim() : null;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public Date getNgayDangKy() {
        return ngayDangKy;
    }

    public void setNgayDangKy(Date ngayDangKy) {
        this.ngayDangKy = ngayDangKy;
    }

    // Các hàm Getter phụ trợ để bảo mật che giấu thông tin hiển thị (Masking)
    public String getMaskedSoDienThoai() {
        if (soDienThoai == null || soDienThoai.trim().isEmpty()) {
            return "";
        }
        String cleanPhone = soDienThoai.trim();
        int len = cleanPhone.length();
        if (len <= 6) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < len; i++) {
                sb.append("*");
            }
            return sb.toString();
        }
        StringBuilder sb = new StringBuilder();
        sb.append(cleanPhone.substring(0, 3));
        for (int i = 0; i < len - 6; i++) {
            sb.append("*");
        }
        sb.append(cleanPhone.substring(len - 3));
        return sb.toString();
    }

    public String getMaskedHoTen() {
        if (hoTen == null || hoTen.trim().isEmpty()) {
            return "";
        }
        String[] words = hoTen.trim().split("\\s+");
        if (words.length == 0) {
            return "";
        }
        if (words.length == 1) {
            String w = words[0];
            if (w.length() <= 1) {
                return "*";
            }
            StringBuilder sb = new StringBuilder();
            sb.append(w.charAt(0));
            for (int i = 1; i < w.length(); i++) {
                sb.append("*");
            }
            return sb.toString();
        }
        if (words.length == 2) {
            return words[0] + " *";
        }
        return words[0] + " * " + words[words.length - 1];
    }
}
