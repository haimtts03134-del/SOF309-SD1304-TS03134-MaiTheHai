package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Bộ lọc bảo mật chặn các yêu cầu chưa đăng nhập truy cập vào khu vực /admin/*.
 * Kiểm tra quyền Admin bảo mật dựa trên thuộc tính hasAdminAccess và vai trò người dùng.
 */
@WebFilter("/admin/*")
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String loginURI = contextPath + "/admin/login";
        String logoutURI = contextPath + "/admin/logout";

        boolean isLoginRequest = requestURI.equals(loginURI) || requestURI.endsWith("login.jsp");
        boolean isLogoutRequest = requestURI.equals(logoutURI);
        boolean isCssRequest = requestURI.contains("/admin/css/");

        boolean loggedIn = (session != null && (
            session.getAttribute("adminUser") != null || 
            session.getAttribute("adminEmail") != null || 
            session.getAttribute("staffUser") != null
        ));

        boolean hasAdminPrivilege = (session != null) && (
            Boolean.TRUE.equals(session.getAttribute("hasAdminAccess")) ||
            "ADMIN".equalsIgnoreCase((String) session.getAttribute("userRole")) ||
            "QUANLY".equalsIgnoreCase((String) session.getAttribute("userRole")) ||
            "admin@qrcoffee.com".equalsIgnoreCase((String) session.getAttribute("adminEmail")) ||
            "admin@qrcoffee.com".equalsIgnoreCase((String) session.getAttribute("adminUser"))
        );

        if (hasAdminPrivilege || isLoginRequest || isLogoutRequest || isCssRequest) {
            chain.doFilter(request, response);
        } else {
            // Không có quyền Admin hoặc chưa đăng nhập: Chuyển về trang Đăng nhập Quản trị
            httpResponse.sendRedirect(loginURI);
        }
    }

    @Override
    public void destroy() {
    }
}
