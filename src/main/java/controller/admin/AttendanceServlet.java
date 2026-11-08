package controller.admin;

import dao.AttendanceDao;
import dao.UserDao;
import entity.Attendance;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Servlet xử lý quản lý Chấm công và Tính ca làm việc nhân viên cho Quản trị viên (Admin).
 */
@WebServlet("/admin/attendance")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AttendanceDao attendanceDao;
    private UserDao userDao;
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat DATETIME_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    @Override
    public void init() throws ServletException {
        attendanceDao = new AttendanceDao();
        userDao = new UserDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteAttendance(request, response);
                    break;
                case "list":
                default:
                    listAttendance(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "insert";
        }

        try {
            switch (action) {
                case "insert":
                    insertAttendance(request, response);
                    break;
                case "update":
                    updateAttendance(request, response);
                    break;
                case "quick-batch":
                    quickBatchAttendance(request, response);
                    break;
                default:
                    listAttendance(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // Hiển thị danh sách chấm công & bộ lọc
    private void listAttendance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String dateParam = request.getParameter("date");
        String keyword = request.getParameter("keyword");

        Date selectedDate = null;
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                selectedDate = DATE_FORMAT.parse(dateParam);
            } catch (ParseException e) {
                selectedDate = new Date();
            }
        } else {
            // Mặc định là ngày hôm nay nếu không truyền param
            selectedDate = new Date();
            dateParam = DATE_FORMAT.format(selectedDate);
        }

        // Tự động quét và điểm danh kết thúc ca cho các ca quá giờ
        attendanceDao.autoCheckoutExpiredShifts(new Date());

        List<Attendance> attendanceList = attendanceDao.searchAttendance(selectedDate, keyword);
        List<User> employees = userDao.findAll();
        Map<String, Long> dailyStats = attendanceDao.getDailyStats(selectedDate);

        // Tính tổng số nhân viên và số nhân viên đi làm
        long totalEmployees = employees.stream().filter(u -> "HoatDong".equalsIgnoreCase(u.getTrangThai())).count();
        long coMatCount = dailyStats.getOrDefault("CoMat", 0L);
        long diMuonCount = dailyStats.getOrDefault("DiMuon", 0L);
        long veSomCount = dailyStats.getOrDefault("VeSom", 0L);
        long vangCount = dailyStats.getOrDefault("Vang", 0L);
        long nghiPhepCount = dailyStats.getOrDefault("NghiPhep", 0L);

        request.setAttribute("attendanceList", attendanceList);
        request.setAttribute("employees", employees);
        request.setAttribute("selectedDateStr", dateParam);
        request.setAttribute("keyword", keyword);

        request.setAttribute("totalEmployees", totalEmployees);
        request.setAttribute("coMatCount", coMatCount);
        request.setAttribute("diMuonCount", diMuonCount);
        request.setAttribute("veSomCount", veSomCount);
        request.setAttribute("vangCount", vangCount);
        request.setAttribute("nghiPhepCount", nghiPhepCount);

        request.getRequestDispatcher("/admin/attendance.jsp").forward(request, response);
    }

    // Đổ dữ liệu cần sửa lên Form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Attendance existingAttendance = attendanceDao.findById(id);

        String dateParam = request.getParameter("date");
        Date selectedDate = null;
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try { selectedDate = DATE_FORMAT.parse(dateParam); } catch (Exception ignored) {}
        } else if (existingAttendance != null) {
            selectedDate = existingAttendance.getNgayChamCong();
            dateParam = DATE_FORMAT.format(selectedDate);
        }

        List<Attendance> attendanceList = attendanceDao.searchAttendance(selectedDate, null);
        List<User> employees = userDao.findAll();
        Map<String, Long> dailyStats = attendanceDao.getDailyStats(selectedDate);

        request.setAttribute("attendanceList", attendanceList);
        request.setAttribute("employees", employees);
        request.setAttribute("selectedAttendance", existingAttendance);
        request.setAttribute("isEdit", true);
        request.setAttribute("selectedDateStr", dateParam);

        request.setAttribute("totalEmployees", employees.stream().filter(u -> "HoatDong".equalsIgnoreCase(u.getTrangThai())).count());
        request.setAttribute("coMatCount", dailyStats.getOrDefault("CoMat", 0L));
        request.setAttribute("diMuonCount", dailyStats.getOrDefault("DiMuon", 0L));
        request.setAttribute("veSomCount", dailyStats.getOrDefault("VeSom", 0L));
        request.setAttribute("vangCount", dailyStats.getOrDefault("Vang", 0L));
        request.setAttribute("nghiPhepCount", dailyStats.getOrDefault("NghiPhep", 0L));

        request.getRequestDispatcher("/admin/attendance.jsp").forward(request, response);
    }

    // Thêm bản ghi chấm công thủ công
    private void insertAttendance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int maNguoiDung = Integer.parseInt(request.getParameter("maNguoiDung"));
        String ngayChamCongStr = request.getParameter("ngayChamCong");
        String tenCa = request.getParameter("tenCa");
        String gioVaoStr = request.getParameter("gioVao");
        String gioRaStr = request.getParameter("gioRa");
        String trangThai = request.getParameter("trangThai");
        String ghiChu = request.getParameter("ghiChu");

        User user = userDao.findById(maNguoiDung);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/admin/attendance");
            return;
        }

        Date ngayChamCong = new Date();
        try {
            if (ngayChamCongStr != null && !ngayChamCongStr.trim().isEmpty()) {
                ngayChamCong = DATE_FORMAT.parse(ngayChamCongStr);
            }
        } catch (ParseException e) {
            ngayChamCong = new Date();
        }

        Date gioVao = parseTime(ngayChamCongStr, gioVaoStr);
        Date gioRa = parseTime(ngayChamCongStr, gioRaStr);

        double soGioLam = 0.0;
        String soGioLamParam = request.getParameter("soGioLam");
        if (soGioLamParam != null && !soGioLamParam.trim().isEmpty()) {
            try {
                soGioLam = Double.parseDouble(soGioLamParam);
            } catch (NumberFormatException ignored) {}
        } else if (gioVao != null && gioRa != null) {
            long diffMs = gioRa.getTime() - gioVao.getTime();
            if (diffMs > 0) {
                soGioLam = Math.round((diffMs / (1000.0 * 60.0 * 60.0)) * 10.0) / 10.0;
            }
        }

        Attendance newAtt = new Attendance(user, ngayChamCong, tenCa, gioVao, gioRa, soGioLam, trangThai, ghiChu);
        try {
            attendanceDao.create(newAtt);
            response.sendRedirect(request.getContextPath() + "/admin/attendance?date=" + DATE_FORMAT.format(ngayChamCong));
        } catch (Exception ex) {
            request.setAttribute("errorMessage", "Không thể thêm chấm công (Có thể nhân viên đã được chấm công ngày này): " + ex.getMessage());
            listAttendance(request, response);
        }
    }

    // Cập nhật bản ghi chấm công
    private void updateAttendance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        int maNguoiDung = Integer.parseInt(request.getParameter("maNguoiDung"));
        String ngayChamCongStr = request.getParameter("ngayChamCong");
        String tenCa = request.getParameter("tenCa");
        String gioVaoStr = request.getParameter("gioVao");
        String gioRaStr = request.getParameter("gioRa");
        String trangThai = request.getParameter("trangThai");
        String ghiChu = request.getParameter("ghiChu");

        Attendance att = attendanceDao.findById(id);
        User user = userDao.findById(maNguoiDung);

        if (att != null && user != null) {
            Date ngayChamCong = att.getNgayChamCong();
            try {
                if (ngayChamCongStr != null && !ngayChamCongStr.trim().isEmpty()) {
                    ngayChamCong = DATE_FORMAT.parse(ngayChamCongStr);
                }
            } catch (ParseException ignored) {}

            Date gioVao = parseTime(ngayChamCongStr, gioVaoStr);
            Date gioRa = parseTime(ngayChamCongStr, gioRaStr);

            double soGioLam = 0.0;
            String soGioLamParam = request.getParameter("soGioLam");
            if (soGioLamParam != null && !soGioLamParam.trim().isEmpty()) {
                try {
                    soGioLam = Double.parseDouble(soGioLamParam);
                } catch (NumberFormatException ignored) {}
            } else if (gioVao != null && gioRa != null) {
                long diffMs = gioRa.getTime() - gioVao.getTime();
                if (diffMs > 0) {
                    soGioLam = Math.round((diffMs / (1000.0 * 60.0 * 60.0)) * 10.0) / 10.0;
                }
            }

            att.setUser(user);
            att.setNgayChamCong(ngayChamCong);
            att.setTenCa(tenCa);
            att.setGioVao(gioVao);
            att.setGioRa(gioRa);
            att.setSoGioLam(soGioLam);
            att.setTrangThai(trangThai);
            att.setGhiChu(ghiChu);

            try {
                attendanceDao.update(att);
                response.sendRedirect(request.getContextPath() + "/admin/attendance?date=" + DATE_FORMAT.format(ngayChamCong));
            } catch (Exception ex) {
                request.setAttribute("errorMessage", "Không thể cập nhật chấm công: " + ex.getMessage());
                listAttendance(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/attendance");
        }
    }

    // Xóa bản ghi chấm công
    private void deleteAttendance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String dateStr = request.getParameter("date");
        attendanceDao.delete(id);
        if (dateStr != null && !dateStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/attendance?date=" + dateStr);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/attendance");
        }
    }

    // Điểm danh nhanh hàng loạt cho toàn bộ nhân viên trong ngày
    private void quickBatchAttendance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String dateParam = request.getParameter("batchDate");
        String defaultCa = request.getParameter("defaultCa");
        if (defaultCa == null || defaultCa.trim().isEmpty()) {
            defaultCa = "Ca Sáng (07:00 - 13:00)";
        }

        Date targetDate = new Date();
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                targetDate = DATE_FORMAT.parse(dateParam);
            } catch (ParseException ignored) {}
        }

        List<User> employees = userDao.findAll();
        int countAdded = 0;

        for (User emp : employees) {
            if ("HoatDong".equalsIgnoreCase(emp.getTrangThai())) {
                Attendance existing = attendanceDao.findByUserAndDate(emp.getMaNguoiDung(), targetDate);
                if (existing == null) {
                    Date gioVao = parseTime(DATE_FORMAT.format(targetDate), "07:00");
                    Date gioRa = parseTime(DATE_FORMAT.format(targetDate), "13:00");
                    Attendance newAtt = new Attendance(emp, targetDate, defaultCa, gioVao, gioRa, 6.0, "CoMat", "Điểm danh hàng loạt");
                    try {
                        attendanceDao.create(newAtt);
                        countAdded++;
                    } catch (Exception ignored) {}
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/attendance?date=" + DATE_FORMAT.format(targetDate));
    }

    // Utility hỗ trợ parse thời gian từ date (YYYY-MM-DD) và time (HH:mm)
    private Date parseTime(String dateStr, String timeStr) {
        if (timeStr == null || timeStr.trim().isEmpty() || dateStr == null || dateStr.trim().isEmpty()) {
            return null;
        }
        try {
            return DATETIME_FORMAT.parse(dateStr.trim() + " " + timeStr.trim());
        } catch (ParseException e) {
            return null;
        }
    }
}
