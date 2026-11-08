package entity;

import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.io.Serializable;

/**
 * Entity đại diện cho bảng NguoiDung (Người dùng / Tài khoản nhân viên).
 */
@Entity
@Table(name = "NguoiDung") 
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaNguoiDung")
    private int maNguoiDung;

    @Column(name = "HoTen", nullable = false, length = 100)
    private String hoTen;

    @Column(name = "Email", unique = true, length = 100)
    private String email;

    @Column(name = "SoDienThoai", unique = true, length = 15)
    private String soDienThoai;

    @Column(name = "MatKhau", nullable = false, length = 255)
    private String matKhau;

    @Column(name = "TrangThai", length = 20)
    private String trangThai = "HoatDong"; // HoatDong, Khoa

    @ManyToOne
    @JoinColumn(name = "MaVaiTro")
    private Role role;

    @Column(name = "HinhAnh", columnDefinition = "TEXT")
    private String hinhAnh;

    public User() {
    }

    public User(String hoTen, String email, String soDienThoai, String matKhau, String trangThai, Role role) {
        this.hoTen = hoTen;
        this.email = email;
        this.soDienThoai = soDienThoai;
        this.matKhau = matKhau;
        this.trangThai = trangThai;
        this.role = role;
    }

    // Getters and Setters
    public int getMaNguoiDung() {
        return maNguoiDung;
    }

    public void setMaNguoiDung(int maNguoiDung) {
        this.maNguoiDung = maNguoiDung;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getEmail() {
        return email != null ? email.trim() : null;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getMatKhau() {
        return matKhau != null ? matKhau.trim() : null;
    }

    public void setMatKhau(String matKhau) {
        this.matKhau = matKhau;
    }

    public String getTrangThai() {
        return trangThai != null ? trangThai.trim() : null;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }
}
