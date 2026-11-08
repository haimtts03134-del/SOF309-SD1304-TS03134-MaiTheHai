package controller.admin;

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
 * Servlet xử lý các chức năng Thêm, Sửa, Xóa, Hiển thị (CRUD) cho đối tượng Thức uống (Drinks / SanPham).
 */
@WebServlet("/admin/drinks")
public class DrinkServlet extends HttpServlet {
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
                    deleteDrink(request, response);
                    break;
                case "list":
                default:
                    listDrinks(request, response);
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
                    insertDrink(request, response);
                    break;
                case "update":
                    updateDrink(request, response);
                    break;
                default:
                    listDrinks(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // Hiển thị danh sách đồ uống
    private void listDrinks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Drink> drinks = drinkDao.findAll();
        List<Category> categories = categoryDao.findAll();
        
        request.setAttribute("drinks", drinks);
        request.setAttribute("categories", categories);
        
        request.getRequestDispatcher("/admin/drinks.jsp").forward(request, response);
    }

    // Đổ dữ liệu món cần sửa lên Form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Drink existingDrink = drinkDao.findById(id);
        
        List<Drink> drinks = drinkDao.findAll();
        List<Category> categories = categoryDao.findAll();

        request.setAttribute("drinks", drinks);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedDrink", existingDrink);
        request.setAttribute("isEdit", true); // Đánh dấu là đang ở chế độ chỉnh sửa

        request.getRequestDispatcher("/admin/drinks.jsp").forward(request, response);
    }

    // Thêm mới món nước
    private void insertDrink(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String name = request.getParameter("tenSanPham");
        double price = Double.parseDouble(request.getParameter("giaCoBan"));
        String image = request.getParameter("hinhAnh");
        String desc = request.getParameter("moTa");
        String status = request.getParameter("trangThai");
        int categoryId = Integer.parseInt(request.getParameter("maDanhMuc"));

        Category category = categoryDao.findById(categoryId);
        Drink newDrink = new Drink(name, price, image, desc, status, category);

        drinkDao.create(newDrink);
        response.sendRedirect(request.getContextPath() + "/admin/drinks");
    }

    // Cập nhật thông tin món nước
    private void updateDrink(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("tenSanPham");
        double price = Double.parseDouble(request.getParameter("giaCoBan"));
        String image = request.getParameter("hinhAnh");
        String desc = request.getParameter("moTa");
        String status = request.getParameter("trangThai");
        int categoryId = Integer.parseInt(request.getParameter("maDanhMuc"));

        Category category = categoryDao.findById(categoryId);
        Drink drink = drinkDao.findById(id);
        
        if (drink != null) {
            drink.setTenSanPham(name);
            drink.setGiaCoBan(price);
            drink.setHinhAnh(image);
            drink.setMoTa(desc);
            drink.setTrangThai(status);
            drink.setCategory(category);
            
            drinkDao.update(drink);
        }

        response.sendRedirect(request.getContextPath() + "/admin/drinks");
    }

    // Xóa món nước
    private void deleteDrink(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        drinkDao.delete(id);
        response.sendRedirect(request.getContextPath() + "/admin/drinks");
    }
}
