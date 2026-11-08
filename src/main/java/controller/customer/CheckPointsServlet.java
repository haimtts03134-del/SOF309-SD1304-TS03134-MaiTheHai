package controller.customer;

import dao.CustomerDao;
import entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet tra cứu điểm tích lũy của khách hàng theo Số điện thoại.
 */
@WebServlet("/check-points")
public class CheckPointsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CustomerDao customerDao;

    @Override
    public void init() throws ServletException {
        customerDao = new CustomerDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String phone = request.getParameter("phone");
        String name = request.getParameter("name");
        String query = request.getParameter("query");

        String keyword = query != null ? query : (name != null ? name : phone);

        if (keyword == null || keyword.trim().isEmpty()) {
            out.print("{\"exists\": false, \"points\": 0, \"customers\": []}");
            return;
        }

        keyword = keyword.trim();

        try {
            // Tra cứu chính xác theo SĐT nếu keyword khớp định dạng SĐT
            if (phone != null && !phone.trim().isEmpty()) {
                Customer customer = customerDao.findByPhone(phone.trim());
                if (customer != null) {
                    String safeName = customer.getHoTen() != null ? customer.getHoTen().replace("\"", "\\\"") : "";
                    String safePhone = customer.getSoDienThoai() != null ? customer.getSoDienThoai().replace("\"", "\\\"") : "";
                    int points = customer.getDiemTichLuy();
                    out.print("{\"exists\": true, \"name\": \"" + safeName + "\", \"phone\": \"" + safePhone + "\", \"points\": " + points + "}");
                    return;
                }
            }

            // Gợi ý danh sách khách hàng khớp với từ khóa Tên hoặc SĐT
            java.util.List<Customer> list = customerDao.searchByNameOrPhone(keyword);
            if (!list.isEmpty()) {
                StringBuilder json = new StringBuilder();
                json.append("{\"exists\": true, \"customers\": [");
                for (int i = 0; i < list.size(); i++) {
                    Customer c = list.get(i);
                    String safeName = c.getHoTen() != null ? c.getHoTen().replace("\"", "\\\"") : "";
                    String safePhone = c.getSoDienThoai() != null ? c.getSoDienThoai().replace("\"", "\\\"") : "";
                    json.append("{\"name\": \"").append(safeName)
                        .append("\", \"phone\": \"").append(safePhone)
                        .append("\", \"points\": ").append(c.getDiemTichLuy()).append("}");
                    if (i < list.size() - 1) {
                        json.append(",");
                    }
                }
                json.append("]}");
                out.print(json.toString());
            } else {
                out.print("{\"exists\": false, \"points\": 0, \"customers\": []}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"exists\": false, \"points\": 0, \"error\": \"" + e.getMessage() + "\", \"customers\": []}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
