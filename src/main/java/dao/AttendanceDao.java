package dao;

import entity.Attendance;
import entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import utils.JpaUtils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Lớp DAO quản lý cơ sở dữ liệu cho bảng ChamCong (Chấm công nhân viên).
 */
public class AttendanceDao {

    /**
     * Lấy toàn bộ danh sách chấm công (Sắp xếp mới nhất lên đầu).
     */
    public List<Attendance> findAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT a FROM Attendance a LEFT JOIN FETCH a.user u LEFT JOIN FETCH u.role ORDER BY a.ngayChamCong DESC, a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm bản ghi chấm công theo ID.
     */
    public Attendance findById(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(Attendance.class, id);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm danh sách chấm công theo một ngày cụ thể (YYYY-MM-DD).
     */
    public List<Attendance> findByDate(Date date) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT a FROM Attendance a LEFT JOIN FETCH a.user u LEFT JOIN FETCH u.role WHERE a.ngayChamCong = :date ORDER BY a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            query.setParameter("date", date);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lọc danh sách chấm công theo chuỗi ngày (YYYY-MM-DD) và tên/email nhân viên.
     */
    public List<Attendance> searchAttendance(Date dateFilter, String keyword) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT a FROM Attendance a LEFT JOIN FETCH a.user u LEFT JOIN FETCH u.role WHERE 1=1");
            if (dateFilter != null) {
                jpql.append(" AND a.ngayChamCong = :dateFilter");
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                jpql.append(" AND (LOWER(u.hoTen) LIKE :kw OR LOWER(u.email) LIKE :kw OR u.soDienThoai LIKE :kw)");
            }
            jpql.append(" ORDER BY a.ngayChamCong DESC, a.maChamCong DESC");

            TypedQuery<Attendance> query = em.createQuery(jpql.toString(), Attendance.class);
            if (dateFilter != null) {
                query.setParameter("dateFilter", dateFilter);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");
            }
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm bản ghi chấm công theo Mã Nhân Viên và Ngày (So sánh dải ngày trong cùng 1 ngày).
     */
    public Attendance findByUserAndDate(int userId, Date date) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            Date startOfDay = truncateToDate(date);
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(startOfDay);
            cal.add(java.util.Calendar.DAY_OF_MONTH, 1);
            Date endOfDay = cal.getTime();

            String jpql = "SELECT a FROM Attendance a WHERE a.user.maNguoiDung = :userId AND a.ngayChamCong >= :startOfDay AND a.ngayChamCong < :endOfDay ORDER BY a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            query.setParameter("userId", userId);
            query.setParameter("startOfDay", startOfDay);
            query.setParameter("endOfDay", endOfDay);
            List<Attendance> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    private Date truncateToDate(Date date) {
        if (date == null) date = new Date();
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(date);
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        cal.set(java.util.Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    /**
     * Thêm mới bản ghi chấm công.
     */
    public Attendance create(Attendance attendance) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(attendance);
            tx.commit();
            return attendance;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi tạo bản ghi chấm công: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật bản ghi chấm công.
     */
    public Attendance update(Attendance attendance) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Attendance updated = em.merge(attendance);
            tx.commit();
            return updated;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật bản ghi chấm công: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Xóa bản ghi chấm công theo ID.
     */
    public void delete(int id) {
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Attendance attendance = em.find(Attendance.class, id);
            if (attendance != null) {
                em.remove(attendance);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi xóa bản ghi chấm công: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm bản ghi ca làm việc đang hoạt động (Đã Check-in nhưng Chưa Check-out) của Nhân viên.
     */
    public Attendance findActiveShiftByUser(int userId, Date date) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT a FROM Attendance a WHERE a.user.maNguoiDung = :userId AND a.gioVao IS NOT NULL AND a.gioRa IS NULL ORDER BY a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            query.setParameter("userId", userId);
            List<Attendance> list = query.getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Lấy toàn bộ lịch sử chấm công của 1 Nhân viên theo tháng (Lấy mốc năm/tháng từ một ngày).
     */
    public List<Attendance> findByUserMonthly(int userId, int year, int month) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT a FROM Attendance a WHERE a.user.maNguoiDung = :userId AND FUNCTION('YEAR', a.ngayChamCong) = :year AND FUNCTION('MONTH', a.ngayChamCong) = :month ORDER BY a.ngayChamCong DESC, a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            query.setParameter("userId", userId);
            query.setParameter("year", year);
            query.setParameter("month", month);
            return query.getResultList();
        } catch (Exception ex) {
            // Dự phòng nếu DB dialect không hỗ trợ FUNCTION('YEAR')
            String fallbackJpql = "SELECT a FROM Attendance a WHERE a.user.maNguoiDung = :userId ORDER BY a.ngayChamCong DESC, a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(fallbackJpql, Attendance.class);
            query.setParameter("userId", userId);
            query.setMaxResults(100);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy danh sách chấm công mới nhất của 1 Nhân viên.
     */
    public List<Attendance> findByUser(int userId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT a FROM Attendance a WHERE a.user.maNguoiDung = :userId ORDER BY a.ngayChamCong DESC, a.maChamCong DESC";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            query.setParameter("userId", userId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy chuỗi Hash nhanh dữ liệu chấm công hôm nay (MaxId-Count-CheckoutCount) hỗ trợ Polling Realtime.
     */
    public String getTodayAttendanceHash(Date date) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            String jpql = "SELECT MAX(a.maChamCong), COUNT(a), SUM(CASE WHEN a.gioRa IS NOT NULL THEN 1 ELSE 0 END) FROM Attendance a WHERE a.ngayChamCong = :date";
            List<Object[]> result = em.createQuery(jpql, Object[].class).setParameter("date", date).getResultList();
            if (!result.isEmpty() && result.get(0)[0] != null) {
                Object[] row = result.get(0);
                return row[0] + "-" + row[1] + "-" + row[2];
            }
            return "0-0-0";
        } catch (Exception ex) {
            return "0-0-0";
        } finally {
            em.close();
        }
    }

    /**
     * Lấy thống kê số lượng nhân viên theo trạng thái trong ngày cụ thể.
     */
    public Map<String, Long> getDailyStats(Date date) {
        EntityManager em = JpaUtils.getEntityManager();
        Map<String, Long> stats = new HashMap<>();
        try {
            String jpql = "SELECT a.trangThai, COUNT(a) FROM Attendance a WHERE a.ngayChamCong = :date GROUP BY a.trangThai";
            List<Object[]> results = em.createQuery(jpql, Object[].class)
                    .setParameter("date", date)
                    .getResultList();

            stats.put("CoMat", 0L);
            stats.put("DiMuon", 0L);
            stats.put("VeSom", 0L);
            stats.put("Vang", 0L);
            stats.put("NghiPhep", 0L);

            for (Object[] row : results) {
                String status = (String) row[0];
                Long count = (Long) row[1];
                if (status != null) {
                    stats.put(status.trim(), count);
                }
            }
            return stats;
        } finally {
            em.close();
        }
    }

    /**
     * Tự động điểm danh kết thúc ca (Auto Check-out) cho tất cả nhân viên chưa bấm kết thúc ca mà đã quá giờ ca làm.
     * Return số lượng bản ghi đã được tự động kết thúc ca.
     */
    public int autoCheckoutExpiredShifts(Date now) {
        if (now == null) {
            now = new Date();
        }
        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        int countUpdated = 0;
        try {
            String jpql = "SELECT a FROM Attendance a WHERE a.gioVao IS NOT NULL AND a.gioRa IS NULL";
            TypedQuery<Attendance> query = em.createQuery(jpql, Attendance.class);
            List<Attendance> activeList = query.getResultList();

            if (activeList.isEmpty()) {
                return 0;
            }

            tx.begin();
            for (Attendance att : activeList) {
                Date gioVao = att.getGioVao();
                if (gioVao == null) continue;

                java.util.Calendar endCal = java.util.Calendar.getInstance();
                if (att.getNgayChamCong() != null) {
                    endCal.setTime(att.getNgayChamCong());
                } else {
                    endCal.setTime(gioVao);
                }

                String tenCa = att.getTenCa();
                int endHour = 13;
                int endMinute = 0;

                if (tenCa != null) {
                    String lowerCa = tenCa.toLowerCase();
                    if (lowerCa.contains("linh hoạt") || lowerCa.contains("linh hoat")) {
                        endHour = 23;
                        endMinute = 59;
                    } else if (lowerCa.contains("chiều") || lowerCa.contains("14:00")) {
                        endHour = 19;
                        endMinute = 0;
                    } else if (lowerCa.contains("đêm") || lowerCa.contains("tối") || lowerCa.contains("19:30")) {
                        endHour = 22;
                        endMinute = 30;
                    } else {
                        endHour = 13;
                        endMinute = 0;
                    }
                }

                endCal.set(java.util.Calendar.HOUR_OF_DAY, endHour);
                endCal.set(java.util.Calendar.MINUTE, endMinute);
                endCal.set(java.util.Calendar.SECOND, 0);
                endCal.set(java.util.Calendar.MILLISECOND, 0);

                Date shiftEndTarget = endCal.getTime();

                // Nếu thời điểm hiện tại đã vượt quá giờ kết thúc ca
                if (now.after(shiftEndTarget)) {
                    Date gioRa = shiftEndTarget.after(gioVao) ? shiftEndTarget : now;
                    att.setGioRa(gioRa);

                    long diffMs = gioRa.getTime() - gioVao.getTime();
                    double soGio = 0.0;
                    if (diffMs > 0) {
                        soGio = Math.round((diffMs / (1000.0 * 60.0 * 60.0)) * 10.0) / 10.0;
                    }
                    att.setSoGioLam(soGio);

                    String oldNote = att.getGhiChu();
                    String autoNote = "Tự động điểm danh kết thúc ca (Quên ra ca thủ công)";
                    if (oldNote != null && !oldNote.trim().isEmpty()) {
                        if (!oldNote.contains("Tự động điểm danh kết thúc ca")) {
                            att.setGhiChu(oldNote + " (" + autoNote + ")");
                        }
                    } else {
                        att.setGhiChu(autoNote);
                    }

                    em.merge(att);
                    countUpdated++;
                }
            }
            tx.commit();
            return countUpdated;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            return 0;
        } finally {
            em.close();
        }
    }

    /**
     * Tự động điểm danh VÀO CA ngay tại thời điểm nhân viên Đăng nhập tài khoản.
     * Tự động nhận diện khung giờ hiện tại để xác định ca làm (Sáng, Chiều, Tối),
     * tính toán trạng thái Có mặt / Đi muộn và tạo/cập nhật bản ghi chấm công.
     * 
     * @param user Nhân viên đăng nhập
     * @param now Thời điểm đăng nhập
     * @return Chuỗi thông báo kết quả tự động điểm danh (hoặc null nếu đã có ca)
     */
    public String autoCheckInOnLogin(User user, Date now) {
        if (user == null) return null;
        if (now == null) now = new Date();

        try {
            // 1. Kiểm tra xem nhân viên đã có ca làm việc đang hoạt động hay chưa
            Attendance activeShift = findActiveShiftByUser(user.getMaNguoiDung(), now);
            if (activeShift != null) {
                return null;
            }

            // 2. Kiểm tra xem nhân viên đã hoàn thành (Ra ca) ca làm của khung giờ hiện tại hay chưa
            Attendance todayCompleted = findByUserAndDate(user.getMaNguoiDung(), now);
            if (todayCompleted != null && todayCompleted.getGioRa() != null) {
                return null;
            }

            // 3. Tự động nhận diện khung giờ ca làm việc hiện tại
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(now);
            int currentMinutes = cal.get(java.util.Calendar.HOUR_OF_DAY) * 60 + cal.get(java.util.Calendar.MINUTE);

            String shiftName;
            int startHour, startMinute;

            if (currentMinutes < 13 * 60 + 30) {
                shiftName = "Ca Sáng (07:00 - 13:00)";
                startHour = 7;
                startMinute = 0;
            } else if (currentMinutes < 19 * 60 + 15) {
                shiftName = "Ca Chiều (14:00 - 19:00)";
                startHour = 14;
                startMinute = 0;
            } else {
                shiftName = "Ca Tối (19:30 - 22:30)";
                startHour = 19;
                startMinute = 30;
            }

            // 4. Tính toán trạng thái Đi muộn hay Đúng giờ (Cho phép trễ 15 phút)
            java.util.Calendar shiftStartCal = java.util.Calendar.getInstance();
            shiftStartCal.setTime(now);
            shiftStartCal.set(java.util.Calendar.HOUR_OF_DAY, startHour);
            shiftStartCal.set(java.util.Calendar.MINUTE, startMinute + 15);
            shiftStartCal.set(java.util.Calendar.SECOND, 0);

            String trangThai = "CoMat";
            String ghiChu = "Tự động điểm danh khi đăng nhập (Đúng giờ)";

            if (now.after(shiftStartCal.getTime())) {
                trangThai = "DiMuon";
                long lateMinutes = (now.getTime() - (shiftStartCal.getTimeInMillis() - 15 * 60 * 1000)) / (1000 * 60);
                ghiChu = "Tự động điểm danh khi đăng nhập (Đi muộn " + lateMinutes + " phút)";
            }

            // 5. Lưu bản ghi vào CSDL
            if (todayCompleted != null && todayCompleted.getGioVao() == null) {
                todayCompleted.setGioVao(now);
                todayCompleted.setTenCa(shiftName);
                todayCompleted.setTrangThai(trangThai);
                todayCompleted.setGhiChu(ghiChu);
                update(todayCompleted);
            } else {
                Attendance newAtt = new Attendance(user, truncateToDate(now), shiftName, now, null, 0.0, trangThai, ghiChu);
                create(newAtt);
            }

            String timeStr = new SimpleDateFormat("HH:mm").format(now);
            return "Đã tự động điểm danh vào " + shiftName + " lúc " + timeStr + " (" + 
                   ("CoMat".equals(trangThai) ? "Có mặt đúng giờ" : ghiChu) + ")";
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
