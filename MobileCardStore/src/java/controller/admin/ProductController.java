package controller.admin;

import DAO.admin.ProductDAO;
import Models.Product;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.nio.file.Paths;

/**
 * Product Controller
 * Xử lý CRUD operations cho quản lý sản phẩm
 */
@WebServlet(name = "ProductController", urlPatterns = {"/plist", "/admin/products"})
@MultipartConfig
public class ProductController extends HttpServlet {
    
    private ProductDAO productDAO;
    private static final String PRODUCT_UPLOAD_DIR = "img/product";
    
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
            } else if ("toggleStatus".equals(action)) {
                toggleStatus(request, response);
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
            } else if ("toggleStatus".equals(action)) {
                toggleStatus(request, response);
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
            String pageParam = request.getParameter("page");
            int page = 1;
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                    if (page < 1) page = 1;
                } catch (NumberFormatException ignored) {
                    page = 1;
                }
            }
            
            int pageSize = 5;
            int offset = (page - 1) * pageSize;
            
            // Search & filter params
            String searchKeyword = request.getParameter("search");
            String statusFilter = request.getParameter("statusFilter");
            String priceRange = request.getParameter("priceRange");
            String sortBy = request.getParameter("sortBy");
            String sortType = request.getParameter("sortType");
            
            if (statusFilter == null || statusFilter.isEmpty()) statusFilter = "ALL";
            if (priceRange == null || priceRange.isEmpty()) priceRange = "ALL";
            if (sortBy == null || sortBy.isEmpty()) sortBy = "CREATED";
            if (sortType == null || sortType.isEmpty()) sortType = "DESC";
            
            request.setAttribute("products", productDAO.searchProductsForAdmin(
                    searchKeyword, statusFilter, null, priceRange, sortBy, sortType, offset, pageSize
            ));
            request.setAttribute("providers", productDAO.getAllProviders());
            
            int total = productDAO.countProductsForAdmin(searchKeyword, statusFilter, null, priceRange);
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("searchKeyword", searchKeyword);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("priceRangeFilter", priceRange);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("sortType", sortType);
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
            throws IOException, ServletException {
        try {
            Product product = new Product();
            product.setProviderId(Integer.parseInt(request.getParameter("providerId")));
            product.setProductName(request.getParameter("productName"));
            product.setPrice(new BigDecimal(request.getParameter("price")));
            String description = request.getParameter("description");
            if (description == null || description.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/plist?action=add&error=missing_description");
                return;
            }
            product.setDescription(description.trim());
            
            String uploadedImage = handleImageUpload(request, product.getProductName());
            if (uploadedImage == null || uploadedImage.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/plist?action=add&error=missing_image");
                return;
            }
            product.setImageUrl(uploadedImage);
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
            throws IOException, ServletException {
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
            
            String existingImageUrl = request.getParameter("existingImageUrl");
            if (existingImageUrl == null || existingImageUrl.isEmpty()) {
                existingImageUrl = product.getImageUrl();
            }
            
            String uploadedImage = handleImageUpload(request, product.getProductName());
            String manualUrl = request.getParameter("imageUrl");
            if (uploadedImage != null && !uploadedImage.isEmpty()) {
                product.setImageUrl(uploadedImage);
            } else if (manualUrl != null && !manualUrl.isEmpty()) {
                product.setImageUrl(manualUrl);
            } else {
                product.setImageUrl(existingImageUrl);
            }
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
    
    private void toggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");
            if (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status)) {
                response.sendRedirect(request.getContextPath() + "/plist?error=invalid_status");
                return;
            }
            if (productDAO.updateStatus(productId, status.toUpperCase())) {
                String successKey = "ACTIVE".equalsIgnoreCase(status) ? "show_success" : "hide_success";
                response.sendRedirect(request.getContextPath() + "/plist?success=" + successKey);
            } else {
                response.sendRedirect(request.getContextPath() + "/plist?error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/plist?error=update_failed");
        }
    }
    
    private String handleImageUpload(HttpServletRequest request, String productName) throws IOException, ServletException {
        Part filePart = request.getPart("avatar");
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        if (fileName.isEmpty()) {
            return null;
        }
        
        String lowerFileName = fileName.toLowerCase();
        if (!(lowerFileName.endsWith(".jpg") || lowerFileName.endsWith(".jpeg") || lowerFileName.endsWith(".png"))) {
            return null;
        }
        
        String safeProductName = productName != null ? productName.replaceAll("[^a-zA-Z0-9-_]", "_") : "product";
        String uploadDirectory = getServletContext().getRealPath(PRODUCT_UPLOAD_DIR + "/" + safeProductName);
        File uploadDir = new File(uploadDirectory);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        String filePath = uploadDirectory + File.separator + fileName;
        try (InputStream input = filePart.getInputStream(); OutputStream output = new FileOutputStream(filePath)) {
            byte[] buffer = new byte[1024];
            int length;
            while ((length = input.read(buffer)) > 0) {
                output.write(buffer, 0, length);
            }
        }
        
        return PRODUCT_UPLOAD_DIR + "/" + safeProductName + "/" + fileName;
    }
}
