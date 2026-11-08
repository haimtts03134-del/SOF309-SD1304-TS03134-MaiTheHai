package controller.api;

import dao.AttendanceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Date;

/**
 * API Servlet hỗ trợ Polling tự động làm mới dữ liệu Bảng Chấm Công Realtime.
 */
@WebServlet("/api/attendance/poll")
public class AttendancePollServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AttendanceDao attendanceDao;

    @Override
    public void init() throws ServletException {
        attendanceDao = new AttendanceDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Date today = new Date();
        attendanceDao.autoCheckoutExpiredShifts(today);
        String hash = attendanceDao.getTodayAttendanceHash(today);

        String json = "{\"hash\":\"" + hash + "\"}";
        response.getWriter().write(json);
    }
}
