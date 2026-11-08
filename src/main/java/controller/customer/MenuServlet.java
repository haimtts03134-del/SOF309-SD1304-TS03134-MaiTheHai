package controller.customer;

import dao.CategoryDao;
import dao.DrinkDao;
import entity.Category;
import entity.Drink;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet hiển thị thực đơn đồ uống cho khách hàng (Không cần đăng nhập).
 */
@WebServlet("/menu")
public class MenuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DrinkDao drinkDao;
    private CategoryDao categoryDao;

    @Override
    public void init() throws ServletException {
        drinkDao = new DrinkDao();
        categoryDao = new CategoryDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Tải danh sách đồ uống đang bán
        List<Drink> drinks = drinkDao.findActive();
        
        // Tải danh sách danh mục để làm bộ lọc
        List<Category> categories = categoryDao.findAll();

        // Tải danh sách bàn của quán
        dao.TableDao tableDao = new dao.TableDao();
        List<entity.Table> tables = tableDao.findAll();

        // Tự động nhận diện bàn ăn từ mã QR (Tham số URL: table, tableId, hoặc qr)
        String tableParam = request.getParameter("table");
        if (tableParam == null || tableParam.trim().isEmpty()) tableParam = request.getParameter("tableId");
        if (tableParam == null || tableParam.trim().isEmpty()) tableParam = request.getParameter("qr");

        // Nếu URL không có tham số bàn, thử đọc từ Session
        if (tableParam == null || tableParam.trim().isEmpty()) {
            Object sessTableIdObj = request.getSession().getAttribute("sessionTableId");
            if (sessTableIdObj != null) {
                tableParam = String.valueOf(sessTableIdObj);
            }
        }

        // Nếu Session chưa có, thử đọc từ Cookie trình duyệt (bộ nhớ 1 ngày)
        if (tableParam == null || tableParam.trim().isEmpty()) {
            jakarta.servlet.http.Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (jakarta.servlet.http.Cookie c : cookies) {
                    if ("coffee_table_id".equals(c.getName()) && c.getValue() != null && !c.getValue().trim().isEmpty()) {
                        tableParam = c.getValue().trim();
                        break;
                    }
                }
            }
        }

        if (tableParam != null && !tableParam.trim().isEmpty()) {
            tableParam = tableParam.trim();
            entity.Table matchedTable = null;
            try {
                int tableId = Integer.parseInt(tableParam);
                matchedTable = tableDao.findById(tableId);
            } catch (NumberFormatException e) {
                // Thử tìm theo mã QR Code hoặc Tên bàn
                matchedTable = tableDao.findByQR(tableParam);
                if (matchedTable == null) {
                    matchedTable = tableDao.findByTenBan(tableParam);
                }
            }

            if (matchedTable != null) {
                request.setAttribute("scannedTable", matchedTable);
                request.getSession().setAttribute("sessionTableId", matchedTable.getMaBan());
                request.getSession().setAttribute("sessionTableName", matchedTable.getTenBan());

                // Ghi nhớ Cookie 24 giờ cho lần truy cập tiếp theo
                jakarta.servlet.http.Cookie tableCookie = new jakarta.servlet.http.Cookie("coffee_table_id", String.valueOf(matchedTable.getMaBan()));
                tableCookie.setMaxAge(24 * 60 * 60);
                tableCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                response.addCookie(tableCookie);
            }
        }

        // Xóa sạch Cookie thông tin khách hàng cũ trên máy khách để tránh dùng nhầm tài khoản/điểm tích lũy
        jakarta.servlet.http.Cookie[] allCookies = request.getCookies();
        if (allCookies != null) {
            for (jakarta.servlet.http.Cookie c : allCookies) {
                if ("coffee_cust_name".equals(c.getName()) || "coffee_cust_phone".equals(c.getName())) {
                    jakarta.servlet.http.Cookie cleanCookie = new jakarta.servlet.http.Cookie(c.getName(), "");
                    cleanCookie.setMaxAge(0);
                    cleanCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                    response.addCookie(cleanCookie);
                }
            }
        }

        request.setAttribute("drinks", drinks);
        request.setAttribute("categories", categories);
        request.setAttribute("tables", tables);

        // Chuyển tiếp tới trang giao diện menu khách hàng (nằm trong thư mục customer)
        request.getRequestDispatcher("/customer/menu.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
