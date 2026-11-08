package controller.staff;

import dao.AttendanceDao;
import dao.UserDao;
import entity.Attendance;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Servlet xử lý Chấm công & Điểm danh phía Nhân viên (/staff/attendance).
 * Tự động xác định Ca làm việc (Ca Sáng: 7h-13h, Ca Chiều: 14h-19h, Ca Tối: 19h30-22h30),
 * tự động đánh giá trạng thái Có mặt / Đi muộn / Về sớm và tính số giờ làm.
 */
@WebServlet("/staff/attendance")
public class StaffAttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AttendanceDao attendanceDao;
    private UserDao userDao;
    private static final SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("HH:mm");

    @Override
    public void init() throws ServletException {
        attendanceDao = new AttendanceDao();
        userDao = new UserDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User staffUser = getLoggedInUser(request);
        if (staffUser == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        // Đồng bộ thuộc tính hiển thị tên và avatar tài khoản nhân viên vào session
        request.getSession().setAttribute("staffName", staffUser.getHoTen());
        if (staffUser.getHinhAnh() != null) {
            request.getSession().setAttribute("staffAvatar", staffUser.getHinhAnh());
        }

        Date today = Calendar.getInstance().getTime();

        // 0. Tự động kiểm tra và điểm danh kết thúc ca cho các ca quá giờ
        attendanceDao.autoCheckoutExpiredShifts(today);

        // 0b. Tự động điểm danh vào ca nếu chưa vào ca
        String autoCheckInMsg = attendanceDao.autoCheckInOnLogin(staffUser, today);
        if (autoCheckInMsg != null && request.getSession().getAttribute("staffSuccessMsg") == null) {
            request.getSession().setAttribute("staffSuccessMsg", autoCheckInMsg);
        }

        // 1. Tìm bản ghi ca làm việc đang hoạt động (Đã vào ca nhưng chưa ra ca)
        Attendance activeShift = attendanceDao.findActiveShiftByUser(staffUser.getMaNguoiDung(), today);

        // 2. Tìm bản ghi chấm công đã hoàn thành hôm nay (nếu có)
        Attendance todayCompletedShift = attendanceDao.findByUserAndDate(staffUser.getMaNguoiDung(), today);

        // 3. Tự động nhận diện ca làm đề xuất cho giờ hiện tại
        ShiftConfig currentShiftConfig = determineShiftConfig(today);

        // 4. Lấy lịch sử chấm công cá nhân của nhân viên
        List<Attendance> personalHistory = attendanceDao.findByUser(staffUser.getMaNguoiDung());

        // 5. Tính toán các chỉ số cá nhân trong tháng
        int totalShiftsThisMonth = 0;
        double totalHoursThisMonth = 0.0;
        int onTimeCount = 0;
        int lateCount = 0;

        Calendar cal = Calendar.getInstance();
        int currentMonth = cal.get(Calendar.MONTH);
        int currentYear = cal.get(Calendar.YEAR);

        for (Attendance att : personalHistory) {
            if (att.getNgayChamCong() != null) {
                cal.setTime(att.getNgayChamCong());
                if (cal.get(Calendar.MONTH) == currentMonth && cal.get(Calendar.YEAR) == currentYear) {
                    totalShiftsThisMonth++;
                    totalHoursThisMonth += att.getSoGioLam();
                    if ("CoMat".equalsIgnoreCase(att.getTrangThai())) {
                        onTimeCount++;
                    } else if ("DiMuon".equalsIgnoreCase(att.getTrangThai())) {
                        lateCount++;
                    }
                }
            }
        }

        // Kiểm tra xem nhân viên đã hoàn thành (Ra ca) ca làm của khung giờ hiện tại hay chưa
        boolean isCurrentShiftCompleted = false;
        String completedShiftName = "";
        String nextShiftMessage = "";

        if (activeShift == null && todayCompletedShift != null && todayCompletedShift.getGioRa() != null) {
            String completedCa = todayCompletedShift.getTenCa();
            Calendar currentCal = Calendar.getInstance();
            int currentMinutes = currentCal.get(Calendar.HOUR_OF_DAY) * 60 + currentCal.get(Calendar.MINUTE);

            if (completedCa != null) {
                if (completedCa.contains("Sáng") && currentMinutes < 13 * 60 + 30) {
                    isCurrentShiftCompleted = true;
                    completedShiftName = "Ca Sáng (07:00 - 13:00)";
                    nextShiftMessage = "Bạn đã hoàn thành và Ra ca cho Ca Sáng hôm nay. Hệ thống sẽ mở lại điểm danh cho Ca Chiều (từ 14:00)!";
                } else if (completedCa.contains("Chiều") && currentMinutes >= 13 * 60 + 30 && currentMinutes < 19 * 60 + 15) {
                    isCurrentShiftCompleted = true;
                    completedShiftName = "Ca Chiều (14:00 - 19:00)";
                    nextShiftMessage = "Bạn đã hoàn thành và Ra ca cho Ca Chiều hôm nay. Hệ thống sẽ mở lại điểm danh cho Ca Tối (từ 19:30)!";
                } else if ((completedCa.contains("Đêm") || completedCa.contains("Tối")) && currentMinutes >= 19 * 60 + 15) {
                    isCurrentShiftCompleted = true;
                    completedShiftName = "Ca Tối (19:30 - 22:30)";
                    nextShiftMessage = "Bạn đã hoàn thành và Ra ca cho Ca Tối hôm nay. Hệ thống sẽ mở lại điểm danh cho Ca Sáng ngày mai (từ 07:00)!";
                }
            }
        }

        request.setAttribute("staffUser", staffUser);
        request.setAttribute("activeShift", activeShift);
        request.setAttribute("todayCompletedShift", todayCompletedShift);
        request.setAttribute("isCurrentShiftCompleted", isCurrentShiftCompleted);
        request.setAttribute("completedShiftName", completedShiftName);
        request.setAttribute("nextShiftMessage", nextShiftMessage);
        request.setAttribute("currentShiftConfig", currentShiftConfig);
        request.setAttribute("personalHistory", personalHistory);
        request.setAttribute("totalShiftsThisMonth", totalShiftsThisMonth);
        request.setAttribute("totalHoursThisMonth", Math.round(totalHoursThisMonth * 10.0) / 10.0);
        request.setAttribute("onTimeCount", onTimeCount);
        request.setAttribute("lateCount", lateCount);
        request.setAttribute("currentTab", "attendance");

        request.getRequestDispatcher("/staff/attendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User staffUser = getLoggedInUser(request);
        if (staffUser == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        Date now = new Date();

        if ("checkin".equalsIgnoreCase(action)) {
            // Nghiệp vụ VÀO CA (CHECK-IN)
            Attendance existingActive = attendanceDao.findActiveShiftByUser(staffUser.getMaNguoiDung(), now);
            if (existingActive == null) {
                String selectedCa = request.getParameter("tenCa");
                ShiftConfig config;

                if (selectedCa != null && !selectedCa.trim().isEmpty()) {
                    config = parseShiftConfigByName(selectedCa);
                } else {
                    config = determineShiftConfig(now);
                }

                boolean isFlexible = config.getShiftName() != null && 
                        (config.getShiftName().toLowerCase().contains("linh hoạt") || config.getShiftName().toLowerCase().contains("linh hoat"));

                String trangThai = "CoMat";
                String ghiChu = isFlexible ? "Ca làm linh hoạt" : "Vào ca đúng giờ";

                if (!isFlexible) {
                    // Kiểm tra trạng thái đi làm: Cho phép trễ 15 phút so với giờ bắt đầu ca
                    Calendar shiftStartCal = Calendar.getInstance();
                    shiftStartCal.setTime(now);
                    shiftStartCal.set(Calendar.HOUR_OF_DAY, config.getStartHour());
                    shiftStartCal.set(Calendar.MINUTE, config.getStartMinute() + 15); // Cho phép trễ 15p
                    shiftStartCal.set(Calendar.SECOND, 0);

                    if (now.after(shiftStartCal.getTime())) {
                        trangThai = "DiMuon";
                        long lateMinutes = (now.getTime() - (shiftStartCal.getTimeInMillis() - 15 * 60 * 1000)) / (1000 * 60);
                        ghiChu = "Đi muộn " + lateMinutes + " phút";
                    }
                }

                // Kiểm tra xem có bản ghi ca được Admin phân sẵn (chưa vào ca: gioVao == null) hay không
                Attendance todayAssigned = attendanceDao.findByUserAndDate(staffUser.getMaNguoiDung(), now);
                if (todayAssigned != null && todayAssigned.getGioVao() == null) {
                    todayAssigned.setGioVao(now);
                    todayAssigned.setTenCa(config.getShiftName());
                    todayAssigned.setTrangThai(trangThai);
                    todayAssigned.setGhiChu(ghiChu);
                    try {
                        attendanceDao.update(todayAssigned);
                        request.getSession().setAttribute("staffSuccessMsg", "Vào ca thành công! Trạng thái: " + 
                                ("CoMat".equals(trangThai) ? "Có mặt (" + config.getShiftName() + ")" : "Đi muộn (" + ghiChu + ")"));
                    } catch (Exception ex) {
                        request.getSession().setAttribute("staffErrorMsg", "Lỗi vào ca: " + ex.getMessage());
                    }
                } else {
                    Attendance newAtt = new Attendance(staffUser, now, config.getShiftName(), now, null, 0.0, trangThai, ghiChu);
                    try {
                        attendanceDao.create(newAtt);
                        request.getSession().setAttribute("staffSuccessMsg", "Vào ca thành công! Trạng thái: " + 
                                ("CoMat".equals(trangThai) ? "Có mặt (" + config.getShiftName() + ")" : "Đi muộn (" + ghiChu + ")"));
                    } catch (Exception ex) {
                        request.getSession().setAttribute("staffErrorMsg", "Lỗi vào ca: " + ex.getMessage());
                    }
                }
            }
        } else if ("checkout".equalsIgnoreCase(action)) {
            // Nghiệp vụ RA CA (CHECK-OUT)
            int attId = 0;
            String attIdStr = request.getParameter("maChamCong");
            if (attIdStr != null && !attIdStr.trim().isEmpty()) {
                try { attId = Integer.parseInt(attIdStr); } catch (Exception ignored) {}
            }

            Attendance activeAtt = null;
            if (attId > 0) {
                activeAtt = attendanceDao.findById(attId);
            } else {
                activeAtt = attendanceDao.findActiveShiftByUser(staffUser.getMaNguoiDung(), now);
            }

            if (activeAtt != null && activeAtt.getGioRa() == null) {
                activeAtt.setGioRa(now);
                Date gioVao = activeAtt.getGioVao();

                double soGio = 0.0;
                if (gioVao != null) {
                    long diffMs = now.getTime() - gioVao.getTime();
                    if (diffMs > 0) {
                        soGio = Math.round((diffMs / (1000.0 * 60.0 * 60.0)) * 10.0) / 10.0;
                    }
                }
                activeAtt.setSoGioLam(soGio);

                boolean isFlexible = activeAtt.getTenCa() != null && 
                        (activeAtt.getTenCa().toLowerCase().contains("linh hoạt") || activeAtt.getTenCa().toLowerCase().contains("linh hoat"));

                if (!isFlexible) {
                    // Kiểm tra xem có ra ca sớm không đối với các ca cố định
                    ShiftConfig config = parseShiftConfigByName(activeAtt.getTenCa());
                    Calendar shiftEndCal = Calendar.getInstance();
                    shiftEndCal.setTime(now);
                    shiftEndCal.set(Calendar.HOUR_OF_DAY, config.getEndHour());
                    shiftEndCal.set(Calendar.MINUTE, config.getEndMinute() - 10); // Sớm hơn 10p coi như về sớm

                    if (now.before(shiftEndCal.getTime()) && "CoMat".equalsIgnoreCase(activeAtt.getTrangThai())) {
                        activeAtt.setTrangThai("VeSom");
                        activeAtt.setGhiChu("Về sớm lúc " + TIME_FORMAT.format(now));
                    }
                }

                try {
                    attendanceDao.update(activeAtt);
                    
                    // Đăng xuất an toàn khỏi hệ thống để bàn giao ca
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        session.invalidate();
                    }

                    String msg = "Đã kết thúc ca làm thành công! (Tổng thời gian: " + soGio + " giờ). Tài khoản đã được đăng xuất an toàn để bàn giao ca.";
                    response.sendRedirect(request.getContextPath() + "/admin/login?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
                    return;
                } catch (Exception ex) {
                    request.getSession().setAttribute("staffErrorMsg", "Lỗi ra ca: " + ex.getMessage());
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/staff/attendance");
    }

    // Lấy thông tin User đang đăng nhập từ Session
    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;

        String email = (String) session.getAttribute("staffUser");
        if (email == null || email.trim().isEmpty()) {
            email = (String) session.getAttribute("adminEmail");
        }
        if (email == null || email.trim().isEmpty()) {
            email = (String) session.getAttribute("adminUser");
        }

        if (email != null && !email.trim().isEmpty()) {
            return userDao.findByEmail(email.trim());
        }
        return null;
    }

    // Tự động nhận diện Ca làm việc dựa theo khung giờ hiện tại
    private ShiftConfig determineShiftConfig(Date now) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(now);
        int currentMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE);

        // Khung giờ Ca Sáng: 07:00 - 13:00
        // Khung giờ Ca Chiều: 14:00 - 19:00
        // Khung giờ Ca Tối: 19:30 - 22:30

        if (currentMinutes < 13 * 60 + 30) { // Trước 13h30 -> Ca Sáng
            return new ShiftConfig("Ca Sáng (07:00 - 13:00)", 7, 0, 13, 0);
        } else if (currentMinutes < 19 * 60 + 15) { // 13h30 đến 19h15 -> Ca Chiều
            return new ShiftConfig("Ca Chiều (14:00 - 19:00)", 14, 0, 19, 0);
        } else { // Từ 19h15 trở đi -> Ca Tối
            return new ShiftConfig("Ca Tối (19:30 - 22:30)", 19, 30, 22, 30);
        }
    }

    private ShiftConfig parseShiftConfigByName(String shiftName) {
        if (shiftName == null) {
            return new ShiftConfig("Ca Sáng (07:00 - 13:00)", 7, 0, 13, 0);
        }
        String lower = shiftName.toLowerCase();
        if (lower.contains("linh hoạt") || lower.contains("linh hoat")) {
            return new ShiftConfig("Ca Linh Hoạt", 0, 0, 23, 59);
        } else if (lower.contains("chiều") || lower.contains("14:00")) {
            return new ShiftConfig("Ca Chiều (14:00 - 19:00)", 14, 0, 19, 0);
        } else if (lower.contains("đêm") || lower.contains("tối") || lower.contains("19:30")) {
            return new ShiftConfig("Ca Tối (19:30 - 22:30)", 19, 30, 22, 30);
        } else {
            return new ShiftConfig("Ca Sáng (07:00 - 13:00)", 7, 0, 13, 0);
        }
    }

    // Inner Helper Class chứa cấu hình giờ Ca làm việc
    public static class ShiftConfig {
        private String shiftName;
        private int startHour;
        private int startMinute;
        private int endHour;
        private int endMinute;

        public ShiftConfig(String shiftName, int startHour, int startMinute, int endHour, int endMinute) {
            this.shiftName = shiftName;
            this.startHour = startHour;
            this.startMinute = startMinute;
            this.endHour = endHour;
            this.endMinute = endMinute;
        }

        public String getShiftName() { return shiftName; }
        public int getStartHour() { return startHour; }
        public int getStartMinute() { return startMinute; }
        public int getEndHour() { return endHour; }
        public int getEndMinute() { return endMinute; }

        public String getDisplayTime() {
            return String.format("%02d:%02d - %02d:%02d", startHour, startMinute, endHour, endMinute);
        }
    }
}
