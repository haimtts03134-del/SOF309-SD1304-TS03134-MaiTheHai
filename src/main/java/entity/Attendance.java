package entity;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Date;

/**
 * Entity đại diện cho bảng ChamCong (Chấm công & Ca làm việc nhân viên).
 */
@Entity
@jakarta.persistence.Table(name = "ChamCong")
public class Attendance implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaChamCong")
    private int maChamCong;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaNguoiDung", nullable = false)
    private User user;

    @Temporal(TemporalType.DATE)
    @Column(name = "NgayChamCong", nullable = false)
    private Date ngayChamCong = new Date();

    @Column(name = "TenCa", nullable = false, length = 50)
    private String tenCa = "Ca Sáng (07:00 - 13:00)";

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "GioVao")
    private Date gioVao;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "GioRa")
    private Date gioRa;

    @Column(name = "SoGioLam")
    private double soGioLam = 0.0;

    @Column(name = "TrangThai", length = 30)
    private String trangThai = "CoMat"; // CoMat, DiMuon, VeSom, Vang, NghiPhep

    @Column(name = "GhiChu", length = 255)
    private String ghiChu;

    public Attendance() {
    }

    public Attendance(User user, Date ngayChamCong, String tenCa, Date gioVao, Date gioRa, double soGioLam, String trangThai, String ghiChu) {
        this.user = user;
        this.ngayChamCong = ngayChamCong;
        this.tenCa = tenCa;
        this.gioVao = gioVao;
        this.gioRa = gioRa;
        this.soGioLam = soGioLam;
        this.trangThai = trangThai;
        this.ghiChu = ghiChu;
    }

    public int getMaChamCong() {
        return maChamCong;
    }

    public void setMaChamCong(int maChamCong) {
        this.maChamCong = maChamCong;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Date getNgayChamCong() {
        return ngayChamCong;
    }

    public void setNgayChamCong(Date ngayChamCong) {
        this.ngayChamCong = ngayChamCong;
    }

    public String getTenCa() {
        return tenCa != null ? tenCa.trim() : null;
    }

    public void setTenCa(String tenCa) {
        this.tenCa = tenCa;
    }

    public Date getGioVao() {
        return gioVao;
    }

    public void setGioVao(Date gioVao) {
        this.gioVao = gioVao;
    }

    public Date getGioRa() {
        return gioRa;
    }

    public void setGioRa(Date gioRa) {
        this.gioRa = gioRa;
    }

    public double getSoGioLam() {
        return soGioLam;
    }

    public void setSoGioLam(double soGioLam) {
        this.soGioLam = soGioLam;
    }

    public String getTrangThai() {
        return trangThai != null ? trangThai.trim() : null;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }
}
