package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet xử lý Đăng nhập (Login) và Đăng xuất (Logout) của khu vực quản trị và nhân viên.
 * Hỗ trợ duy trì quyền Admin kể cả khi đăng nhập song song tài khoản Nhân viên trên cùng trình duyệt.
 */
@WebServlet(urlPatterns = {"/admin/login", "/admin/logout"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/admin/logout".equals(path)) {
            String scope = request.getParameter("scope");
            String checkoutParam = request.getParameter("checkout");
            HttpSession session = request.getSession(false);

            if ("true".equalsIgnoreCase(checkoutParam) && session != null) {
                String staffEmail = (String) session.getAttribute("staffUser");
                if (staffEmail == null) staffEmail = (String) session.getAttribute("adminEmail");
                if (staffEmail == null) staffEmail = (String) session.getAttribute("adminUser");

                if (staffEmail != null && !staffEmail.trim().isEmpty()) {
                    dao.UserDao userDao = new dao.UserDao();
                    entity.User user = userDao.findByEmail(staffEmail.trim());

                    if (user != null) {
                        dao.AttendanceDao attendanceDao = new dao.AttendanceDao();
                        java.util.Date now = new java.util.Date();
                        entity.Attendance activeShift = attendanceDao.findActiveShiftByUser(user.getMaNguoiDung(), now);

                        if (activeShift != null && activeShift.getGioRa() == null) {
                            activeShift.setGioRa(now);
                            if (activeShift.getGioVao() != null) {
                                long diffMs = now.getTime() - activeShift.getGioVao().getTime();
                                if (diffMs > 0) {
                                    double hours = Math.round((diffMs / (1000.0 * 60.0 * 60.0)) * 10.0) / 10.0;
                                    activeShift.setSoGioLam(hours);
                                }
                            }
                            String currentNote = activeShift.getGhiChu();
                            activeShift.setGhiChu(currentNote != null && !currentNote.isEmpty() ? currentNote + " (Tự động kết thúc ca khi đăng xuất giao ca)" : "Tự động kết thúc ca khi đăng xuất giao ca");
                            try {
                                attendanceDao.update(activeShift);
                            } catch (Exception ignored) {}
                        }
                    }
                }
            }

            if (session != null) {
                if ("staff".equalsIgnoreCase(scope)) {
                    // Đăng xuất phạm vi Nhân viên: chỉ xóa thuộc tính Nhân viên
                    session.removeAttribute("hasStaffAccess");
                    session.removeAttribute("staffUser");
                    session.removeAttribute("staffName");
                    session.removeAttribute("staffAvatar");
                    session.removeAttribute("staffRole");
                    if (session.getAttribute("adminUser") == null) {
                        session.invalidate();
                    }
                } else if ("admin".equalsIgnoreCase(scope)) {
                    // Đăng xuất phạm vi Admin: chỉ xóa thuộc tính Admin
                    session.removeAttribute("hasAdminAccess");
                    session.removeAttribute("adminUser");
                    session.removeAttribute("adminEmail");
                    session.removeAttribute("adminName");
                    session.removeAttribute("adminAvatar");
                    session.removeAttribute("adminRole");
                    if (session.getAttribute("staffUser") == null) {
                        session.invalidate();
                    }
                } else {
                    // Đăng xuất toàn bộ
                    session.invalidate();
                }
            }
            // Chuyển hướng về trang login kèm cờ action=logout để hiển thị trang Đăng Nhập
            response.sendRedirect(request.getContextPath() + "/admin/login?action=logout");
        } else {
            // Nếu người dùng đã đăng nhập sẵn trong session hiện tại và không gọi action=logout
            String actionParam = request.getParameter("action");
            HttpSession session = request.getSession(false);
            if (!"logout".equalsIgnoreCase(actionParam) && session != null) {
                boolean hasAdminPrivilege = Boolean.TRUE.equals(session.getAttribute("hasAdminAccess")) ||
                        "ADMIN".equalsIgnoreCase((String) session.getAttribute("userRole")) ||
                        "admin@qrcoffee.com".equalsIgnoreCase((String) session.getAttribute("adminEmail")) ||
                        "admin@qrcoffee.com".equalsIgnoreCase((String) session.getAttribute("adminUser"));

                if (hasAdminPrivilege) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    return;
                }
            }

            // Nghiệp vụ hiển thị trang đăng nhập
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) {
            email = email.trim();
        }
        if (password != null) {
            password = password.trim();
        }

        dao.UserDao userDao = new dao.UserDao();
        entity.User user = userDao.findByEmail(email);

        // Kiểm tra thông tin đăng nhập từ cơ sở dữ liệu
        if (user != null && user.getMatKhau().equals(password) && "HoatDong".equals(user.getTrangThai())) {
            
            // Lấy session hiện tại hoặc tạo mới
            HttpSession session = request.getSession(true);
            
            String role = "NHANVIEN";
            if (user.getRole() != null && user.getRole().getMaVaiTro() != null) {
                role = user.getRole().getMaVaiTro().trim();
            }
            
            boolean isAdminUser = "admin@qrcoffee.com".equalsIgnoreCase(email) || 
                                  "ADMIN".equalsIgnoreCase(role) || 
                                  "QUANLY".equalsIgnoreCase(role);

            if (isAdminUser) {
                // Cài đặt thuộc tính độc lập cho phạm vi Admin
                session.setAttribute("hasAdminAccess", true);
                session.setAttribute("adminEmail", email);
                session.setAttribute("adminUser", email);
                session.setAttribute("adminName", user.getHoTen());
                session.setAttribute("adminAvatar", user.getHinhAnh());
                session.setAttribute("adminRole", role);
                session.setAttribute("userRole", "ADMIN");

                // Nếu chưa có tài khoản Nhân viên đăng nhập trong Session, mặc định dùng tài khoản Admin cho cả khu vực Staff
                if (session.getAttribute("staffUser") == null) {
                    session.setAttribute("hasStaffAccess", true);
                    session.setAttribute("staffUser", email);
                    session.setAttribute("staffName", user.getHoTen());
                    session.setAttribute("staffAvatar", user.getHinhAnh());
                    session.setAttribute("staffRole", role);
                }
                session.setMaxInactiveInterval(-1);

                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                // Kiểm tra xem nhân viên đã kết thúc ca làm trong khung giờ hiện tại hay chưa
                dao.AttendanceDao attendanceDao = new dao.AttendanceDao();
                java.util.Date now = new java.util.Date();
                
                // Tự động kiểm tra và điểm danh kết thúc ca cho các ca quá giờ
                attendanceDao.autoCheckoutExpiredShifts(now);

                entity.Attendance todayCompleted = attendanceDao.findByUserAndDate(user.getMaNguoiDung(), now);
                entity.Attendance activeShift = attendanceDao.findActiveShiftByUser(user.getMaNguoiDung(), now);

                if (activeShift == null && todayCompleted != null && todayCompleted.getGioRa() != null) {
                    String completedCa = todayCompleted.getTenCa();
                    java.util.Calendar currentCal = java.util.Calendar.getInstance();
                    int currentMinutes = currentCal.get(java.util.Calendar.HOUR_OF_DAY) * 60 + currentCal.get(java.util.Calendar.MINUTE);

                    boolean blockLogin = false;
                    String blockedMsg = "";

                    if (completedCa != null) {
                        if (completedCa.contains("Sáng") && currentMinutes < 13 * 60 + 30) {
                            blockLogin = true;
                            blockedMsg = "Bạn đã kết thúc Ca Sáng hôm nay! Vui lòng quay lại vào ca tiếp theo (Ca Chiều từ 14:00).";
                        } else if (completedCa.contains("Chiều") && currentMinutes >= 13 * 60 + 30 && currentMinutes < 19 * 60 + 15) {
                            blockLogin = true;
                            blockedMsg = "Bạn đã kết thúc Ca Chiều hôm nay! Vui lòng quay lại vào ca tiếp theo (Ca Tối từ 19:30).";
                        } else if ((completedCa.contains("Đêm") || completedCa.contains("Tối")) && currentMinutes >= 19 * 60 + 15) {
                            blockLogin = true;
                            blockedMsg = "Bạn đã kết thúc Ca Tối hôm nay! Hệ thống sẽ mở lại điểm danh vào Ca Sáng ngày mai (từ 07:00).";
                        }
                    }

                    if (blockLogin) {
                        request.setAttribute("errorMessage", blockedMsg);
                        request.setAttribute("oldEmail", email);
                        request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
                        return;
                    }
                }

                // Cài đặt thuộc tính độc lập cho phạm vi Nhân viên (Staff Scope) - KHÔNG ĐÈ THUỘC TÍNH ADMIN
                session.setAttribute("hasStaffAccess", true);
                session.setAttribute("staffUser", email);
                session.setAttribute("staffName", user.getHoTen());
                session.setAttribute("staffAvatar", user.getHinhAnh());
                session.setAttribute("staffRole", "NHANVIEN");
                session.setMaxInactiveInterval(-1);

                // Tự động điểm danh VÀO CA ngay tại thời điểm nhân viên đăng nhập tài khoản
                String autoCheckInResult = attendanceDao.autoCheckInOnLogin(user, now);
                if (autoCheckInResult != null) {
                    session.setAttribute("orderSuccess", autoCheckInResult);
                    session.setAttribute("staffSuccessMsg", autoCheckInResult);
                }

                response.sendRedirect(request.getContextPath() + "/staff/orders");
            }
        } else {
            // Đăng nhập thất bại: Quay lại trang đăng nhập và hiển thị lỗi
            request.setAttribute("errorMessage", "Email, mật khẩu không chính xác hoặc tài khoản đã bị khóa!");
            request.setAttribute("oldEmail", email); // Giữ lại email đã nhập
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
        }
    }
}
