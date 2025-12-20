package controller.admin;

import DAO.admin.ProductStorageDAO;
import Models.ProductStorage;
import Models.ProductStorageGroup;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;



@WebServlet(name = "ProductStorageController", urlPatterns = {"/pklist", "/admin/storage"})
public class ProductStorageController extends HttpServlet {
    
    private ProductStorageDAO storageDAO;
    
    @Override
    public void init() throws ServletException {
        storageDAO = new ProductStorageDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ki?m tra quy?n admin
        if (!checkAdminPermission(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("details".equals(action)) {
                // Lấy chi tiết thẻ theo product_code (cho popup)
                getCardDetails(request, response);
            } else {
                // List all storage groups (grouped by product_code)
                listStorageGroups(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID không hợp lệ");
            try {
                listStorageGroups(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                listStorageGroups(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
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
            if ("updateStatus".equals(action)) {
                updateProductStatus(request, response);
            } else {
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            try {
                listStorageGroups(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
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
    
    /**
     * Hiển thị danh sách nhóm theo product_code
     */
    private void listStorageGroups(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy các tham số lọc
            String providerName = request.getParameter("providerName");
            String status = request.getParameter("status");
            
            // Lấy danh sách provider names để hiển thị trong dropdown
            List<String> providerNames = storageDAO.getAllProviderNames();
            
            // Lấy danh sách nhóm theo product_code
            List<ProductStorageGroup> groups = storageDAO.getStorageGroupsByProviderAndStatus(providerName, status);
            
            // Lấy status từ product_status cho mỗi group
            for (ProductStorageGroup group : groups) {
                try {
                    String productStatus = storageDAO.getProductStatus(group.getProductCode(), group.getProviderId());
                    group.setProductStatus(productStatus);
                } catch (Exception e) {
                    // Nếu không lấy được, set default
                    group.setProductStatus(group.getAvailableQuantity() > 0 ? "ACTIVE" : "INACTIVE");
                }
            }
            
            // Set attributes
            request.setAttribute("storageGroups", groups);
            request.setAttribute("providerNames", providerNames);
            request.setAttribute("selectedProviderName", providerName);
            request.setAttribute("selectedStatus", status);
            
            request.getRequestDispatcher("/view/ManageStorage.jsp").forward(request, response);
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi kết nối database: " + e.getMessage());
            request.setAttribute("storageGroups", new java.util.ArrayList<>());
            request.setAttribute("providerNames", new java.util.ArrayList<>());
            try {
                request.getRequestDispatcher("/view/ManageStorage.jsp").forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            request.setAttribute("storageGroups", new java.util.ArrayList<>());
            request.setAttribute("providerNames", new java.util.ArrayList<>());
            try {
                request.getRequestDispatcher("/view/ManageStorage.jsp").forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
    
    /**
     * Lấy chi tiết các thẻ theo product_code (cho popup)
     */
    private void getCardDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productCode = request.getParameter("productCode");
            
            if (productCode == null || productCode.trim().isEmpty()) {
                response.getWriter().write("{\"error\": \"Mã sản phẩm không hợp lệ\"}");
                response.setContentType("application/json");
                return;
            }
            
            // Lấy danh sách thẻ theo product_code
            List<ProductStorage> cards = storageDAO.getStorageItemsByProductCode(productCode);
            
            // Convert to JSON
            StringBuilder json = new StringBuilder();
            json.append("[");
            for (int i = 0; i < cards.size(); i++) {
                ProductStorage card = cards.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"storageId\":").append(card.getStorageId()).append(",");
                json.append("\"serialNumber\":\"").append(escapeJson(card.getSerialNumber())).append("\",");
                json.append("\"cardCode\":\"").append(escapeJson(card.getCardCode())).append("\",");
                json.append("\"status\":\"").append(escapeJson(card.getStatus())).append("\",");
                json.append("\"expiryDate\":").append(card.getExpiryDate() != null ? "\"" + card.getExpiryDate() + "\"" : "null").append(",");
                json.append("\"createdAt\":\"").append(card.getCreatedAt() != null ? card.getCreatedAt().toString() : "").append("\"");
                json.append("}");
            }
            json.append("]");
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Cập nhật status của sản phẩm
     */
    private void updateProductStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productCode = request.getParameter("productCode");
            String providerIdStr = request.getParameter("providerId");
            String status = request.getParameter("status");
            
            if (productCode == null || providerIdStr == null || status == null) {
                response.getWriter().write("{\"success\": false, \"error\": \"Thiếu thông tin\"}");
                response.setContentType("application/json");
                return;
            }
            
            int providerId = Integer.parseInt(providerIdStr);
            
            // Lấy user ID từ session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            if (user == null) {
                user = (User) session.getAttribute("info");
            }
            Integer updatedBy = (user != null) ? user.getUserId() : null;
            
            // Update status
            boolean success = storageDAO.updateProductStatus(productCode, providerId, status, updatedBy);
            
            if (success) {
                response.getWriter().write("{\"success\": true, \"message\": \"Cập nhật trạng thái thành công\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"error\": \"Không thể cập nhật trạng thái\"}");
            }
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
