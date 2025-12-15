package controller.admin;

import DAO.admin.ProductDAO;
import Models.Product;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;

/**
 * Product Controller
 * Xử lý CRUD operations cho quản lý sản phẩm
 */
@WebServlet(name = "ProductController", urlPatterns = {"/plist", "/admin/products"})
public class ProductController extends HttpServlet {
    
    private ProductDAO productDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if (action == null || action.isEmpty() || action.equals("list")) {
                // List all products
                listProducts(request, response);
            } else if (action.equals("add")) {
                // Show add form
                showAddForm(request, response);
            } else if (action.equals("edit")) {
                // Show edit form
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/plist?error=invalid_id");
                    return;
                }
                showEditForm(request, response, Integer.parseInt(idParam));
            } else if (action.equals("delete")) {
                // Delete product
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/plist?error=invalid_id");
                    return;
                }
                deleteProduct(request, response, Integer.parseInt(idParam));
            } else {
                listProducts(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/plist?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=server_error");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addProduct(request, response);
            } else if ("edit".equals(action)) {
                updateProduct(request, response);
            } else {
                listProducts(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=server_error");
        }
    }
    
    private boolean checkAdminPermission(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            user = (User) session.getAttribute("info");
        }
        
        String role = null;
        if (user != null) {
            role = user.getRole();
        }
        if (role == null) {
            role = (String) session.getAttribute("role");
        }
        
        if (user == null || (role == null || !"ADMIN".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return false;
        }
        
        return true;
    }
    
    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("products", productDAO.getAllProducts());
            request.setAttribute("providers", productDAO.getAllProviders());
            request.getRequestDispatcher("/view/ManageProducts.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=load_failed");
        }
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("providers", productDAO.getAllProviders());
            request.getRequestDispatcher("/view/ManageProducts.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=load_failed");
        }
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, int productId)
            throws ServletException, IOException {
        try {
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/plist?error=product_not_found");
                return;
            }
            request.setAttribute("product", product);
            request.setAttribute("providers", productDAO.getAllProviders());
            request.getRequestDispatcher("/view/ManageProducts.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=load_failed");
        }
    }
    
    private void addProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            Product product = new Product();
            product.setProviderId(Integer.parseInt(request.getParameter("providerId")));
            product.setProductName(request.getParameter("productName"));
            product.setPrice(new BigDecimal(request.getParameter("price")));
            product.setDescription(request.getParameter("description"));
            product.setImageUrl(request.getParameter("imageUrl"));
            product.setStatus(request.getParameter("status"));
            
            if (productDAO.addProduct(product)) {
                response.sendRedirect(request.getContextPath() + "/plist?success=add_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/plist?error=add_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=add_failed");
        }
    }
    
    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            Product product = productDAO.getProductById(productId);
            
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/plist?error=product_not_found");
                return;
            }
            
            product.setProviderId(Integer.parseInt(request.getParameter("providerId")));
            product.setProductName(request.getParameter("productName"));
            product.setPrice(new BigDecimal(request.getParameter("price")));
            product.setDescription(request.getParameter("description"));
            product.setImageUrl(request.getParameter("imageUrl"));
            product.setStatus(request.getParameter("status"));
            
            if (productDAO.updateProduct(product)) {
                response.sendRedirect(request.getContextPath() + "/plist?success=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/plist?error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=update_failed");
        }
    }
    
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response, int productId)
            throws IOException {
        try {
            if (productDAO.deleteProduct(productId)) {
                response.sendRedirect(request.getContextPath() + "/plist?success=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/plist?error=delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=delete_failed");
        }
    }
}
