package controller.admin;

import dao.TableDao;
import entity.Table;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý các chức năng Quản lý Bàn ăn (CRUD: Thêm, Sửa, Xóa, Danh sách & Thống kê số lượng bàn).
 */
@WebServlet("/admin/tables")
public class TableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private TableDao tableDao;

    @Override
    public void init() throws ServletException {
        tableDao = new TableDao();
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
                    deleteTable(request, response);
                    break;
                case "list":
                default:
                    listTables(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "insert";
        }

        try {
            switch (action) {
                case "insert":
                    insertTable(request, response);
                    break;
                case "update":
                    updateTable(request, response);
                    break;
                default:
                    listTables(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // Hiển thị danh sách bàn & thống kê số lượng
    private void listTables(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Table> tables = tableDao.findAll();
        
        long totalTables = tables.size();
        long emptyCount = 0;
        long occupiedCount = 0;
        long reservedCount = 0;
        long maintenanceCount = 0;

        for (Table t : tables) {
            String status = t.getTrangThai();
            if ("CoKhach".equalsIgnoreCase(status)) {
                occupiedCount++;
            } else if ("DatTruoc".equalsIgnoreCase(status)) {
                reservedCount++;
            } else if ("BaoTri".equalsIgnoreCase(status)) {
                maintenanceCount++;
            } else {
                emptyCount++;
            }
        }

        request.setAttribute("tables", tables);
        request.setAttribute("totalTables", totalTables);
        request.setAttribute("emptyCount", emptyCount);
        request.setAttribute("occupiedCount", occupiedCount);
        request.setAttribute("reservedCount", reservedCount);
        request.setAttribute("maintenanceCount", maintenanceCount);

        request.getRequestDispatcher("/admin/tables.jsp").forward(request, response);
    }

    // Đổ dữ liệu bàn cần sửa lên Form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Table existingTable = tableDao.findById(id);

        request.setAttribute("selectedTable", existingTable);
        request.setAttribute("isEdit", true);
        listTables(request, response);
    }

    // Thêm mới bàn ăn
    private void insertTable(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String tenBan = request.getParameter("tenBan");
        String maCodeQR = request.getParameter("maCodeQR");
        String trangThai = request.getParameter("trangThai");

        if (tenBan != null) tenBan = tenBan.trim();
        if (maCodeQR != null) maCodeQR = maCodeQR.trim();
        if (trangThai == null || trangThai.trim().isEmpty()) trangThai = "Trong";

        try {
            if (tenBan == null || tenBan.isEmpty()) {
                throw new Exception("Tên bàn không được để trống!");
            }

            // Kiểm tra trùng tên bàn
            Table checkName = tableDao.findByTenBan(tenBan);
            if (checkName != null) {
                throw new Exception("Tên bàn '" + tenBan + "' đã tồn tại! Vui lòng chọn tên bàn khác.");
            }

            if (maCodeQR != null && !maCodeQR.isEmpty()) {
                Table checkQR = tableDao.findByQR(maCodeQR);
                if (checkQR != null) {
                    throw new Exception("Mã QR Code '" + maCodeQR + "' đã được gán cho bàn khác!");
                }
            }

            Table newTable = new Table(tenBan, maCodeQR, trangThai);
            tableDao.create(newTable);

            // Tự động sinh mã TABLE_XX chuẩn nếu người dùng để trống
            if (maCodeQR == null || maCodeQR.isEmpty()) {
                String autoQR = String.format("TABLE_%02d", newTable.getMaBan());
                newTable.setMaCodeQR(autoQR);
                tableDao.update(newTable);
            }

            request.getSession().setAttribute("tableSuccess", "Thêm bàn '" + tenBan + "' thành công!");
            response.sendRedirect(request.getContextPath() + "/admin/tables");
        } catch (Exception ex) {
            String msg = ex.getMessage();
            request.setAttribute("errorMessage", msg);
            request.setAttribute("selectedTable", new Table(tenBan, maCodeQR, trangThai));
            listTables(request, response);
        }
    }

    // Cập nhật thông tin bàn ăn
    private void updateTable(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String tenBan = request.getParameter("tenBan");
        String maCodeQR = request.getParameter("maCodeQR");
        String trangThai = request.getParameter("trangThai");

        if (tenBan != null) tenBan = tenBan.trim();
        if (maCodeQR != null) maCodeQR = maCodeQR.trim();

        Table table = tableDao.findById(id);
        if (table != null) {
            try {
                if (tenBan == null || tenBan.isEmpty()) {
                    throw new Exception("Tên bàn không được để trống!");
                }

                // Check trùng tên bàn khác
                Table checkName = tableDao.findByTenBan(tenBan);
                if (checkName != null && checkName.getMaBan() != id) {
                    throw new Exception("Tên bàn '" + tenBan + "' đã tồn tại ở bàn khác!");
                }

                // Check trùng mã QR khác
                if (maCodeQR != null && !maCodeQR.isEmpty()) {
                    Table checkQR = tableDao.findByQR(maCodeQR);
                    if (checkQR != null && checkQR.getMaBan() != id) {
                        throw new Exception("Mã QR Code '" + maCodeQR + "' đã được sử dụng cho bàn khác!");
                    }
                } else {
                    maCodeQR = "TABLE_" + id;
                }

                table.setTenBan(tenBan);
                table.setMaCodeQR(maCodeQR);
                table.setTrangThai(trangThai);

                tableDao.update(table);
                request.getSession().setAttribute("tableSuccess", "Cập nhật thông tin '" + tenBan + "' thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/tables");
            } catch (Exception ex) {
                request.setAttribute("errorMessage", ex.getMessage());
                request.setAttribute("selectedTable", table);
                request.setAttribute("isEdit", true);
                listTables(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/tables");
        }
    }

    // Xóa bàn ăn
    private void deleteTable(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            tableDao.delete(id);
            request.getSession().setAttribute("tableSuccess", "Đã xóa bàn thành công!");
        } catch (Exception ex) {
            request.getSession().setAttribute("tableError", "Không thể xóa bàn này vì đã có lịch sử hóa đơn đặt món liên quan!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/tables");
    }
}
