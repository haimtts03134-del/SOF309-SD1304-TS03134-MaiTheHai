package controller.staff;

import dao.TableDao;
import entity.Table;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet quản lý trạng thái các bàn ăn dành riêng cho nhân viên.
 */
@WebServlet("/staff/tables")
public class StaffTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TableDao tableDao;

    @Override
    public void init() throws ServletException {
        tableDao = new TableDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/staff/orders");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/staff/orders");
    }
}
