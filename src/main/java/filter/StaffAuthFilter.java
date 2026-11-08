package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Bộ lọc bảo mật chặn các yêu cầu chưa đăng nhập truy cập vào khu vực /staff/*.
 * Cho phép cả ADMIN và NHANVIEN truy cập.
 */
@WebFilter("/staff/*")
public class StaffAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean loggedIn = (session != null && (
            session.getAttribute("adminUser") != null || 
            session.getAttribute("staffUser") != null ||
            session.getAttribute("adminEmail") != null
        ));
        
        if (loggedIn) {
            // Tự động đảm bảo thuộc tính hiển thị tên và avatar của tài khoản nhân viên luôn có trong session
            if (session.getAttribute("staffName") == null) {
                String email = (String) session.getAttribute("staffUser");
                if (email == null) email = (String) session.getAttribute("adminEmail");
                if (email == null) email = (String) session.getAttribute("adminUser");

                if (email != null && !email.trim().isEmpty()) {
                    dao.UserDao userDao = new dao.UserDao();
                    entity.User currentUser = userDao.findByEmail(email.trim());
                    if (currentUser != null) {
                        session.setAttribute("staffName", currentUser.getHoTen());
                        if (currentUser.getHinhAnh() != null) {
                            session.setAttribute("staffAvatar", currentUser.getHinhAnh());
                        }
                    }
                }
            }
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/login");
        }
    }

    @Override
    public void destroy() {
    }
}
